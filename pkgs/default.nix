{ pkgs }:
{
  ssh-mcp = pkgs.callPackage ./ssh-mcp/default.nix { };
  codebase-memory-mcp = pkgs.callPackage ./codebase-memory-mcp/default.nix { };
  google-colab-mcp = pkgs.callPackage ./google-colab-mcp/default.nix { };
  telegram-mcp = pkgs.callPackage ./telegram-mcp/default.nix { };
  github-mcp-server = pkgs.callPackage ./github-mcp-server/default.nix { };
  tavily-mcp = pkgs.callPackage ./tavily-mcp/default.nix { };
  server-memory = pkgs.callPackage ./server-memory/default.nix { };
  agentmemory = pkgs.callPackage ./agentmemory/default.nix { };
  sequential-thinking = pkgs.callPackage ./sequential-thinking/default.nix { };
  docker-hub-mcp = pkgs.callPackage ./docker-hub-mcp/default.nix { };
  obsidian-second-brain-mcp = pkgs.callPackage ./obsidian-second-brain-mcp/default.nix { };
  scrapling = pkgs.callPackage ./scrapling/default.nix { };
  ai-memory = pkgs.callPackage ./ai-memory/default.nix { };
}
