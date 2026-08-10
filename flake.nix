{
  description = "Nix-native Model Context Protocol (MCP) servers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?shallow=1&ref=nixos-26.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [ ./nix/flake-module.nix ];
    };
}
