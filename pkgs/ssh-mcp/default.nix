{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "ssh-mcp";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "tufantunc";
    repo = "ssh-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HDnl1gH9kTvzT343yN+PAGDLEHZRV84TZQFoohrZvdo=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    makeWrapper ${nodejs}/bin/node $out/bin/ssh-mcp \
      --add-flags "$out/lib/node_modules/ssh-mcp/build/index.js"
  '';

  meta = {
    description = "MCP server exposing SSH control for Linux and Windows systems";
    homepage = "https://github.com/tufantunc/ssh-mcp";
    license = lib.licenses.mit;
    mainProgram = "ssh-mcp";
    platforms = lib.platforms.all;
  };
})
