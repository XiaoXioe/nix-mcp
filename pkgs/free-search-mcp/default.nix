{
  lib,
  stdenv,
  runCommand,
  python313,
  cacert,
  makeWrapper,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "free-search-mcp";
  version = "0.10.0";

  src =
    runCommand "${finalAttrs.pname}-src"
      {
        nativeBuildInputs = [
          python313
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-8YqSTgO/iJYILIR3vfHQOCeitevKIif0w0sNirDiuQY=";
      }
      ''
        export HOME=$TMPDIR
        export PIP_CACHE_DIR=$TMPDIR/pip-cache
        export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

        python3.13 -m venv $TMPDIR/venv

        $TMPDIR/venv/bin/pip install \
          --target $out/lib/free-search-mcp \
          --no-cache-dir \
          --no-compile \
          "free-search-mcp==${finalAttrs.version}"

        find $out -name "direct_url.json" -delete
        find $out -name "*.pyc" -delete
        find $out -name "__pycache__" -type d -exec rm -rf {} +
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${python313}/bin/python3 $out/bin/free-search-mcp \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib zlib ]}" \
      --add-flags "-c \"import sys, search_mcp.__main__; sys.exit(search_mcp.__main__.main())\"" \
      --set PYTHONPATH "$src/lib/free-search-mcp"
    ln -s $out/bin/free-search-mcp $out/bin/search-mcp
  '';

  meta = {
    description = "Local-first, no-API-key search MCP server";
    homepage = "https://github.com/sweetcornna/free-search-mcp";
    license = lib.licenses.mit;
    mainProgram = "free-search-mcp";
    platforms = lib.platforms.all;
  };
})
