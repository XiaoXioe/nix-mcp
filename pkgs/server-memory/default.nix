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
  version = "1.0.0";

  src =
    runCommand "server-memory-src"
      {
        nativeBuildInputs = [
          nodejs
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-cNZO9k/DTmOnkrmDOGj7sx050qj/uZyTh8D8lvZ8KyY=";
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
