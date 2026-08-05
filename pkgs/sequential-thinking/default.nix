{
  lib,
  stdenv,
  runCommand,
  nodejs,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sequential-thinking";
  version = "2026.7.4";

  src =
    runCommand "sequential-thinking-src"
      {
        nativeBuildInputs = [
          nodejs
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-bbiT4HzYVL3Im5djigiyTgJMdd8CqsYGL8aZg2Wm44Y=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/sequential-thinking
        cd $out/lib/sequential-thinking
        npm install --no-audit --no-fund --production @modelcontextprotocol/server-sequential-thinking@${finalAttrs.version}
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/sequential-thinking
    ln -s $src/lib/sequential-thinking/node_modules $out/lib/sequential-thinking/node_modules
    makeWrapper ${nodejs}/bin/node $out/bin/mcp-server-sequential-thinking \
      --add-flags "$out/lib/sequential-thinking/node_modules/@modelcontextprotocol/server-sequential-thinking/dist/index.js"
  '';

  meta = {
    description = "MCP server for sequential thinking and problem solving";
    homepage = "https://github.com/modelcontextprotocol/servers/tree/main/src/sequential-thinking";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-sequential-thinking";
    platforms = lib.platforms.all;
  };
})
