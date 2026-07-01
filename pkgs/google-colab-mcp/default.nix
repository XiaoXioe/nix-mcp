{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "google-colab-mcp";
  version = "1.0.1";

  src = pkgs.runCommand "${pname}-src"
    {
      nativeBuildInputs = [
        pkgs.python313
        pkgs.cacert
      ];
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = "sha256-Qm/B1ldhd+wec2YKBp8JOUUtfGd//tc8oI+D/B/uObI=";
    }
    ''
      export HOME=$TMPDIR
      export PIP_CACHE_DIR=$TMPDIR/pip-cache
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      
      # Set up venv in TMPDIR just to get pip
      python3.13 -m venv $TMPDIR/venv
      
      # Install directly to the target directory using the venv's pip
      $TMPDIR/venv/bin/pip install \
        --target $out/lib/google-colab-mcp \
        --no-cache-dir \
        --no-compile \
        google-colab-mcp==${version}

      # Clean up non-deterministic files
      find $out -name "direct_url.json" -delete
      find $out -name "*.pyc" -delete
      find $out -name "__pycache__" -type d -exec rm -rf {} +
    '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.python313}/bin/python3 $out/bin/colab-mcp \
      --add-flags "-c \"import sys; from mcp_colab_server import server_main; sys.exit(server_main())\"" \
      --set PYTHONPATH "$src/lib/google-colab-mcp"
  '';
}
