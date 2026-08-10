# modules/home-manager/default.nix
# Home Manager module for nix-mcp — declarative MCP server installation
#
# Usage in home.nix:
#   imports = [ inputs.nix-mcp.homeModules.default ];
#   programs.nix-mcp = {
#     enable = true;
#     enabledServers = [ "ssh-mcp" "tavily-mcp" "sequential-thinking" ];
#   };
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nix-mcp;

  # All available server names (must match pkgs/default.nix keys)
  availableServers = [
    "ssh-mcp"
    "codebase-memory-mcp"
    "google-colab-mcp"
    "telegram-mcp"
    "github-mcp-server"
    "tavily-mcp"
    "server-memory"
    "agentmemory"
    "sequential-thinking"
    "docker-hub-mcp"
    "obsidian-second-brain-mcp"
    "scrapling"
  ];
in
{
  options.programs.nix-mcp = {
    enable = lib.mkEnableOption "nix-mcp MCP server collection";

    enabledServers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum availableServers);
      default = [ ];
      example = [
        "ssh-mcp"
        "tavily-mcp"
        "sequential-thinking"
      ];
      description = ''
        List of MCP server package names to install into the user environment.
        Each name must correspond to a package exported by the nix-mcp flake.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = map (name: pkgs.${name}) cfg.enabledServers;
  };
}
