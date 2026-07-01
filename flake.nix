{
  description = "Nix-native Model Context Protocol (MCP) servers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?shallow=1&ref=nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          ssh-mcp = pkgs.callPackage ./pkgs/ssh-mcp/default.nix {};
          codebase-memory-mcp = pkgs.callPackage ./pkgs/codebase-memory-mcp/default.nix {};
          google-colab-mcp = pkgs.callPackage ./pkgs/google-colab-mcp/default.nix {};
          telegram-mcp = pkgs.callPackage ./pkgs/telegram-mcp/default.nix {};
        }
      );
    };
}
