{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  makeWrapper,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "docker-hub-mcp";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "hub-mcp";
    rev = "2ec06819f48b601e93ab61e5d6763a1d30bd238f";
    hash = "sha256-/LssHTyO/KoLZOjVYQOlEEKATBq4bZ0SdKBC3y1jiO0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    NEW_PACKAGE_JSON=$(mktemp)
    ${jq}/bin/jq 'del(.devDependencies.esbuild) | del(.optionalDependencies) | del(.packages."".optionalDependencies)' package.json > $NEW_PACKAGE_JSON
    mv $NEW_PACKAGE_JSON package.json

    NEW_LOCKFILE=$(mktemp)
    ${jq}/bin/jq 'walk(if type == "object" then with_entries(select(.key | contains("esbuild") | not)) else . end)' package-lock.json > $NEW_LOCKFILE
    mv $NEW_LOCKFILE package-lock.json

    substituteInPlace src/index.ts \
      --replace 'return undefined;' 'return process.env.HUB_USERNAME || process.env.DOCKER_USERNAME;'
  '';

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/dockerhub-mcp-server \
      --add-flags "$out/lib/node_modules/dockerhub-mcp-server/dist/index.js"
  '';

  npmDepsFetcherVersion = 2;
  makeCacheWritable = true;

  npmDepsHash = "sha256-A2voaOOCP0L0bxuXa5sM9gBV3p+mNh7IjmNd770yeTU=";

  meta = {
    description = "Official Docker Hub Model Context Protocol (MCP) server";
    homepage = "https://github.com/docker/hub-mcp";
    license = lib.licenses.mit;
    mainProgram = "dockerhub-mcp-server";
    platforms = lib.platforms.all;
  };
})
