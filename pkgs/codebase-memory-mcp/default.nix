{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  prelink,
  zlib,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "codebase-memory-mcp";
  version = "0.10.5";

  src = fetchurl {
    url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${finalAttrs.version}/codebase-memory-mcp-linux-amd64.tar.gz";
    sha256 = "sha256-MJQXxmDIZO5sWqkNZILNODY1exzROu1fpFdKnowO1bc=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    prelink
    python3
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  postPatch = ''
    python3 -c '
    with open("codebase-memory-mcp", "rb") as f:
        data = bytearray(f.read())

    # Pattern 1: function is_usable_private_directory_parent preamble
    # Bypass parent UID check for userns / sandbox / rootless container compatibility
    p1 = bytes.fromhex("55534881ecb800000064488b04252800000048898424a800000031c085ff")
    idx1 = data.find(p1)
    assert idx1 != -1, "Pattern 1 (is_usable_private_directory_parent) not found"
    data[idx1:idx1+6] = bytes.fromhex("b801000000c3") # mov eax, 1; ret

    # Pattern 2: the two ancestor UID checks in resolve_and_verify_private_directory_path
    p2_func = bytes.fromhex("415741564155415455534881ecd801000064488b04252800000048898424c801000031c04885ff")
    func_start = data.find(p2_func)
    assert func_start != -1, "resolve_and_verify_private_directory_path not found"
    func_end = func_start + 0x600

    idx2 = func_start
    found_checks = 0
    while idx2 < func_end:
        idx2 = data.find(bytes.fromhex("8b54240c39c20f85"), idx2, func_end)
        if idx2 == -1: break
        data[idx2+6:idx2+12] = b"\x90" * 6 # NOP the jne to error
        found_checks += 1
        idx2 += 12
    assert found_checks == 2, f"Expected 2 ancestor checks, found {found_checks}"

    # Pattern 3: owner check before fchmod 0700 in resolve_and_verify_private_directory_path
    p3 = bytes.fromhex("394424040f85")
    idx3 = data.find(p3, func_start, func_end)
    assert idx3 != -1, "Pattern 3 (owner check before fchmod) not found"
    data[idx3+4:idx3+10] = b"\x90" * 6 # NOP the jne to error

    with open("codebase-memory-mcp", "wb") as f:
        f.write(data)
    '
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp codebase-memory-mcp $out/bin/
    chmod +x $out/bin/codebase-memory-mcp
    execstack -c $out/bin/codebase-memory-mcp
  '';

  meta = {
    description = "High-performance local codebase indexing and memory search";
    homepage = "https://github.com/DeusData/codebase-memory-mcp";
    license = lib.licenses.mit;
    mainProgram = "codebase-memory-mcp";
    platforms = [ "x86_64-linux" ];
  };
})
