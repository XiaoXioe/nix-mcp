{
  lib,
  stdenv,
  runCommand,
  nodejs,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "server-memory";
  version = "2.1.1";

  src =
    runCommand "server-memory-src"
      {
        nativeBuildInputs = [
          nodejs
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-c+lElKGNH42XJ3wGETbNUc4bYAyEqOd6ZKx0L2PJ3vw=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/server-memory
        cd $out/lib/server-memory
        npm install --no-audit --no-fund --production @modelcontextprotocol/server-memory@${finalAttrs.version}
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/server-memory
    ln -s $src/lib/server-memory/node_modules $out/lib/server-memory/node_modules
    makeWrapper ${nodejs}/bin/node $out/bin/mcp-server-memory \
      --add-flags "$out/lib/server-memory/node_modules/@modelcontextprotocol/server-memory/dist/index.js"
  '';

  meta = {
    description = "MCP server for enabling memory for Claude through a knowledge graph";
    homepage = "https://github.com/modelcontextprotocol/servers/tree/main/src/memory";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-memory";
    platforms = lib.platforms.all;
  };
})
