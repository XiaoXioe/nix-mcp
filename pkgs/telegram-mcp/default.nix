{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "telegram-mcp-jgalea";
  version = "0.1.2";

  src =
    pkgs.runCommand "${pname}-src"
      {
        nativeBuildInputs = [
          pkgs.python313
          pkgs.cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-DKlTDJ7zchEou4At18HxSljR25zubSeojkXKRj9w6Ww=";
      }
      ''
        export HOME=$TMPDIR
        export PIP_CACHE_DIR=$TMPDIR/pip-cache
        export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

        python3.13 -m venv $TMPDIR/venv

        $TMPDIR/venv/bin/pip install \
          --target $out/lib/telegram-mcp \
          --no-cache-dir \
          --no-compile \
          telegram-mcp-jgalea==${version}

        # Clean up non-deterministic files
        find $out -name "direct_url.json" -delete
        find $out -name "*.pyc" -delete
        find $out -name "__pycache__" -type d -exec rm -rf {} +
      '';

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cat <<EOF > $out/bin/telegram-mcp
    #!${pkgs.python313}/bin/python3
    import sys
    sys.path.insert(0, "$src/lib/telegram-mcp")
    from telegram_mcp.server import main_cli
    if __name__ == "__main__":
        sys.exit(main_cli())
    EOF
    chmod +x $out/bin/telegram-mcp
  '';
}
