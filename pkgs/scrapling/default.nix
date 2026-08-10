{
  lib,
  stdenv,
  runCommand,
  python313,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scrapling";
  version = "0.4.13";

  src =
    runCommand "${finalAttrs.pname}-src"
      {
        nativeBuildInputs = [
          python313
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-+QhmLXk9VTJO2SmAJhRZpr7bqGQUPA0SWk/L9fqAaTM=";
      }
      ''
        export HOME=$TMPDIR
        export PIP_CACHE_DIR=$TMPDIR/pip-cache
        export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

        python3.13 -m venv $TMPDIR/venv

        $TMPDIR/venv/bin/pip install \
          --target $out/lib/scrapling \
          --no-cache-dir \
          --no-compile \
          "scrapling[ai]==${finalAttrs.version}"

        find $out -name "direct_url.json" -delete
        find $out -name "*.pyc" -delete
        find $out -name "__pycache__" -type d -exec rm -rf {} +
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${python313}/bin/python3 $out/bin/scrapling \
      --add-flags "-m scrapling mcp" \
      --set PYTHONPATH "$src/lib/scrapling"
  '';

  meta = {
    description = "Adaptive Web Scraping framework & MCP Server";
    homepage = "https://github.com/D4Vinci/Scrapling";
    license = lib.licenses.bsd3;
    mainProgram = "scrapling";
    platforms = lib.platforms.all;
  };
})
