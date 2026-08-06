{
  lib,
  stdenv,
  runCommand,
  fetchFromGitHub,
  python313,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obsidian-second-brain-mcp";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "eugeniughelbur";
    repo = "obsidian-second-brain";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Iog+4WbRjO9hmOmgf6GH7JCHNlg+VySBTecQA71kIk4=";
  };

  deps =
    runCommand "${finalAttrs.pname}-deps"
      {
        nativeBuildInputs = [
          python313
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-Tap9OFWLXSQRf8JUOBUVMAIeFkT43pQGpsKFBeQv054=";
      }
      ''
        export HOME=$TMPDIR
        export PIP_CACHE_DIR=$TMPDIR/pip-cache
        export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

        python3.13 -m venv $TMPDIR/venv
        $TMPDIR/venv/bin/pip install \
          --target $out/lib/python-deps \
          --no-cache-dir \
          --no-compile \
          "mcp<2"

        # Clean up non-deterministic files
        find $out -name "direct_url.json" -delete
        find $out -name "*.pyc" -delete
        find $out -name "__pycache__" -type d -exec rm -rf {} +
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = false;

  installPhase = ''
    mkdir -p $out/bin $out/lib/obsidian-second-brain-mcp

    # Copy mcp server files from src
    cp -r integrations/obsidian-mcp-server/* $out/lib/obsidian-second-brain-mcp/
    cp -r commands $out/lib/obsidian-second-brain-mcp/commands

    # Patch server.py and vault_ops.py for optional folder parameter
    ${python313}/bin/python3 -c '
    import os
    out = os.environ["out"]
    server_py = os.path.join(out, "lib/obsidian-second-brain-mcp/server.py")
    vault_ops_py = os.path.join(out, "lib/obsidian-second-brain-mcp/vault_ops.py")

    with open(server_py, "r") as f:
        code = f.read()
    code = code.replace("tags: list[str] | None = None,", "tags: list[str] | None = None,\n    folder: str | None = None,")
    code = code.replace("note_type=type, tags=tags)", "note_type=type, tags=tags, folder=folder)")
    with open(server_py, "w") as f:
        f.write(code)

    with open(vault_ops_py, "r") as f:
        code = f.read()
    code = code.replace("    tags: Optional[List[str]] = None,\n) -> Dict[str, Any]:", "    tags: Optional[List[str]] = None,\n    folder: Optional[str] = None,\n) -> Dict[str, Any]:")
    code = code.replace("    inbox = vault / _NOTES_DIR", "    inbox = (vault / folder) if folder else (vault / _NOTES_DIR)")
    with open(vault_ops_py, "w") as f:
        f.write(code)
    '

    # Link dependencies
    ln -s $deps/lib/python-deps/* $out/lib/obsidian-second-brain-mcp/

    # Write wrapper binary
    makeWrapper ${python313}/bin/python3 $out/bin/obsidian-second-brain-mcp \
      --add-flags "$out/lib/obsidian-second-brain-mcp/server.py" \
      --set PYTHONPATH "$out/lib/obsidian-second-brain-mcp" \
      --set OBSIDIAN_COMMANDS_DIR "$out/lib/obsidian-second-brain-mcp/commands"
  '';

  meta = {
    description = "Model Context Protocol (MCP) server for Obsidian Second Brain integration";
    homepage = "https://github.com/eugeniughelbur/obsidian-second-brain";
    license = lib.licenses.mit;
    mainProgram = "obsidian-second-brain-mcp";
    platforms = lib.platforms.all;
  };
})
