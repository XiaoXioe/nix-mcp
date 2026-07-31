{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
}:

buildNpmPackage rec {
  pname = "docker-hub-mcp";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "hub-mcp";
    rev = "2ec06819f48b601e93ab61e5d6763a1d30bd238f";
    hash = "sha256-/LssHTyO/KoLZOjVYQOlEEKATBq4bZ0SdKBC3y1jiO0=";
  };

  # Directly reference jq because buildNpmPackage doesn't pass
  # nativeBuildInputs through to fetchNpmDeps
  postPatch = ''
    NEW_PACKAGE_JSON=$(mktemp)
    ${jq}/bin/jq 'del(.devDependencies.esbuild) | del(.optionalDependencies) | del(.packages."".optionalDependencies)' package.json > $NEW_PACKAGE_JSON
    mv $NEW_PACKAGE_JSON package.json

    NEW_LOCKFILE=$(mktemp)
    ${jq}/bin/jq 'walk(if type == "object" then with_entries(select(.key | contains("esbuild") | not)) else . end)' package-lock.json > $NEW_LOCKFILE
    mv $NEW_LOCKFILE package-lock.json
  '';

  npmDepsFetcherVersion = 2;
  makeCacheWritable = true;

  npmDepsHash = "sha256-A2voaOOCP0L0bxuXa5sM9gBV3p+mNh7IjmNd770yeTU=";

  meta = with lib; {
    description = "Official Docker Hub Model Context Protocol (MCP) server";
    homepage = "https://github.com/docker/hub-mcp";
    license = licenses.mit;
    mainProgram = "dockerhub-mcp-server";
  };
}
