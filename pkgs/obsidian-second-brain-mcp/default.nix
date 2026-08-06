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
