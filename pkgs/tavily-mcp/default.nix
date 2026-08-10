{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "tavily-mcp";
  version = "0.2.22";

  src = fetchFromGitHub {
    owner = "tavily-ai";
    repo = "tavily-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    makeWrapper ${nodejs}/bin/node $out/bin/tavily-mcp \
      --add-flags "$out/lib/node_modules/tavily-mcp/build/index.js"
  '';

  meta = {
    description = "MCP server for advanced web search using Tavily";
    homepage = "https://github.com/tavily-ai/tavily-mcp";
    license = lib.licenses.mit;
    mainProgram = "tavily-mcp";
    platforms = lib.platforms.all;
  };
})
