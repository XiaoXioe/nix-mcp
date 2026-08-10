# lib/default.nix — shared builder helpers for nix-mcp package definitions
{ pkgs }:
{
  # Helper to build an npm-registry CLI tool using buildNpmPackage.
  # Usage: pkgs.callPackage (lib.mkNpmMcp { ... }) {}
  # Parameters:
  #   pname, version: standard
  #   src: fetchFromGitHub or similar
  #   npmDepsHash: sha256 hash from `prefetch-npm-deps`
  #   binName: name of the output binary (default: pname)
  #   npmPackage: node_modules directory name (default: pname)
  #   entryPoint: relative path inside node_modules to the JS entry file
  #   description, homepage, license: meta fields
  mkNpmMcp =
    {
      pname,
      version,
      src,
      npmDepsHash,
      binName ? pname,
      npmPackage ? pname,
      entryPoint,
      description,
      homepage,
      license ? pkgs.lib.licenses.mit,
      extraPostInstall ? "",
      ...
    }:
    pkgs.buildNpmPackage {
      inherit
        pname
        version
        src
        npmDepsHash
        ;

      dontNpmBuild = false;

      nativeBuildInputs = [ pkgs.makeWrapper ];

      postInstall = ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${binName} \
          --add-flags "$out/lib/node_modules/${npmPackage}/${entryPoint}"
        ${extraPostInstall}
      '';

      meta = {
        inherit description homepage license;
        mainProgram = binName;
        platforms = pkgs.lib.platforms.all;
      };
    };
}
