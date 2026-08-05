{
  lib,
  stdenv,
  runCommand,
  python313,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "google-colab-mcp";
  version = "1.0.1";

  src =
    runCommand "${finalAttrs.pname}-src"
      {
        nativeBuildInputs = [
          python313
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-QoxzE4t2YcapRex/ADIhsue6/6hR/huiz2Y5BbGPEHc=";
      }
      ''
        export HOME=$TMPDIR
        export PIP_CACHE_DIR=$TMPDIR/pip-cache
        export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

        # Set up venv in TMPDIR just to get pip
        python3.13 -m venv $TMPDIR/venv

        # Install directly to the target directory using the venv's pip
        $TMPDIR/venv/bin/pip install \
          --target $out/lib/google-colab-mcp \
          --no-cache-dir \
          --no-compile \
          google-colab-mcp==${finalAttrs.version}

        # Clean up non-deterministic files
        find $out -name "direct_url.json" -delete
        find $out -name "*.pyc" -delete
        find $out -name "__pycache__" -type d -exec rm -rf {} +
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${python313}/bin/python3 $out/bin/colab-mcp \
      --add-flags "-c \"import sys; from mcp_colab_server import server_main; sys.exit(server_main())\"" \
      --set PYTHONPATH "$src/lib/google-colab-mcp"
  '';

  meta = {
    description = "Model Context Protocol server for seamless Google Colab integration with AI assistants";
    homepage = "https://github.com/inkbytefo/google-colab-mcp";
    license = lib.licenses.mit;
    mainProgram = "colab-mcp";
    platforms = lib.platforms.all;
  };
})
