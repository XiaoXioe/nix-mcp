{
  lib,
  stdenv,
  runCommand,
  nodejs,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tavily-mcp";
  version = "0.2.21";

  src =
    runCommand "tavily-mcp-src"
      {
        nativeBuildInputs = [
          nodejs
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-2dD0N7M+QJz1MPfj5jlNRewkI42y9zXasS/37P6Cepo=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/tavily-mcp
        cd $out/lib/tavily-mcp
        npm install --no-audit --no-fund --production tavily-mcp@${finalAttrs.version}
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/tavily-mcp
    ln -s $src/lib/tavily-mcp/node_modules $out/lib/tavily-mcp/node_modules
    makeWrapper ${nodejs}/bin/node $out/bin/tavily-mcp \
      --add-flags "$out/lib/tavily-mcp/node_modules/tavily-mcp/build/index.js"
  '';

  meta = {
    description = "MCP server for advanced web search using Tavily";
    homepage = "https://github.com/tavily-ai/tavily-mcp";
    license = lib.licenses.mit;
    mainProgram = "tavily-mcp";
    platforms = lib.platforms.all;
  };
})
