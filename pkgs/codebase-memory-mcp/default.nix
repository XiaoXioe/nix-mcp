{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  prelink,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "codebase-memory-mcp";
  version = "0.10.0";

  src = fetchurl {
    url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${finalAttrs.version}/codebase-memory-mcp-linux-amd64.tar.gz";
    sha256 = "sha256-71ylyN7QL3ANkLBERLwMtn0OlQiDGrRMGk7eAvH6GJw=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    prelink
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

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
