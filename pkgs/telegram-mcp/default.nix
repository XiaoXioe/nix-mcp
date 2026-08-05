{
  lib,
  stdenv,
  runCommand,
  python313,
  cacert,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "telegram-mcp-jgalea";
  version = "0.1.2";

  src =
    runCommand "${finalAttrs.pname}-src"
      {
        nativeBuildInputs = [
          python313
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-DKlTDJ7zchEou4At18HxSljR25zubSeojkXKRj9w6Ww=";
      }
      ''
        export HOME=$TMPDIR
        export PIP_CACHE_DIR=$TMPDIR/pip-cache
        export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

        python3.13 -m venv $TMPDIR/venv

        $TMPDIR/venv/bin/pip install \
          --target $out/lib/telegram-mcp \
          --no-cache-dir \
          --no-compile \
          telegram-mcp-jgalea==${finalAttrs.version}

        # Clean up non-deterministic files
        find $out -name "direct_url.json" -delete
        find $out -name "*.pyc" -delete
        find $out -name "__pycache__" -type d -exec rm -rf {} +
      '';

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cat <<EOF > $out/bin/telegram-mcp
    #!${python313}/bin/python3
    import sys
    sys.path.insert(0, "$src/lib/telegram-mcp")
    from telegram_mcp.server import main_cli
    if __name__ == "__main__":
        sys.exit(main_cli())
    EOF
    chmod +x $out/bin/telegram-mcp
  '';

  meta = {
    description = "Telegram MCP server: give AI tools direct access to your Telegram account";
    homepage = "https://github.com/jgalea/telegram-mcp";
    license = lib.licenses.mit;
    mainProgram = "telegram-mcp";
    platforms = lib.platforms.all;
  };
})
