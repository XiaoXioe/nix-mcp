{ inputs, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      # All packages: `nix build .#ssh-mcp`, `nix build .#tavily-mcp`, etc.
      packages = import ../pkgs { inherit pkgs; };

      # `nix flake check` builds all packages
      checks = config.packages;

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.python3
          pkgs.nix
        ];
        shellHook = "echo 'nix-mcp dev shell ready'";
      };
    };

  flake = {
    # Usage: nixpkgs.overlays = [ inputs.nix-mcp.overlays.default ];
    # Then: pkgs.ssh-mcp, pkgs.tavily-mcp, etc.
    overlays.default = final: _prev: import ../pkgs { pkgs = final; };

    # Usage: imports = [ inputs.nix-mcp.nixosModules.default ];
    nixosModules.default = import ../modules/nixos/default.nix;

    # Usage: imports = [ inputs.nix-mcp.homeModules.default ];
    homeModules.default = import ../modules/home-manager/default.nix;
  };
}
