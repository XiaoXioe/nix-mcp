# Nix Model Context Protocol (MCP) Servers Flake

A Nix Flake repository providing Nix-native packages and builders for various Model Context Protocol (MCP) servers.

This flake allows you to run MCP servers hermetically and declaratively in NixOS or Home Manager configurations without needing global installations of `npm` or `pip`.

---

## Available Packages

This repository contains Nix packaging for the following MCP servers:

*   **`ssh-mcp`**: Remote execution and system control over SSH for MCP clients.
*   **`codebase-memory-mcp`**: High-performance local codebase indexing, semantic search, and graph querying.
*   **`google-colab-mcp`**: Run code cells and manage Google Colab notebooks directly from your AI agent.
*   **`telegram-mcp`**: Direct personal account access using MTProto (Telethon), equipped with a Python-based wrapper to ensure daemon background processes spawn correctly.
*   **`github-mcp-server`**: Direct integration with GitHub's APIs for managing issues, pull requests, repositories, and more.
*   **`tavily-mcp`**: Advanced web search and information extraction leveraging Tavily's APIs.
*   **`server-memory`**: Reference Memory MCP server enabling memory persistence via a knowledge graph.
*   **`agentmemory`**: Standalone agentic memory storage and semantic observation search tool.
*   **`sequential-thinking`**: Sequential thinking and step-by-step reasoning helper for complex problem solving.
*   **`docker-hub-mcp`**: Official Docker Hub MCP server to search and interact with Docker Hub.

---

## Binary Cache (Cachix)

Pre-built binaries and environment dependencies for all packages are cached on [Cachix](https://www.cachix.org/). You can use this cache to avoid building packages from source locally.

### 1. Enable via `nixConfig` (Recommended)
You can declare the substituter natively in your system `flake.nix` by adding the `nixConfig` block:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?shallow=1&ref=nixos-26.05";
    nix-mcp.url = "github:XiaoXioe/nix-mcp";
  };

  # Automatically trust and fetch pre-built binaries from our Cachix cache
  nixConfig = {
    extra-substituters = [ "https://nix-mcp.cachix.org" ];
    extra-trusted-public-keys = [ "nix-mcp.cachix.org-1:fX4XSh0PcNT7FJx0+41n9XxifTVsrFz7vTwMgdLsgig=" ];
  };
  
  # ... rest of your flake
}
```

### 2. Enable via CLI / Nix Configuration
Alternatively, add the cache to your system configuration manually:

Using `cachix` client:
```bash
nix-shell -p cachix --run "cachix use nix-mcp"
```

Or add it to `/etc/nix/nix.conf`:
```conf
substituters = https://cache.nixos.org https://nix-mcp.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-mcp.cachix.org-1:fX4XSh0PcNT7FJx0+41n9XxifTVsrFz7vTwMgdLsgig=
```

---

## How to Consume

### 1. Add to your Flake Inputs

In your system `flake.nix` inputs:

```nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?shallow=1&ref=nixos-26.05";
    
    nix-mcp = {
      url = "github:XiaoXioe/nix-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
```

### 2. Import and Use Packages

You can reference the packages from `inputs.nix-mcp.packages.${system}`:

```nix
{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  telegram-mcp-pkg = inputs.nix-mcp.packages.${system}.telegram-mcp;
in
{
  # Add to your home packages list
  home.packages = [
    telegram-mcp-pkg
  ];

  # Declare mcpServer in config
  home.file.".gemini/config/mcp_config_base.json".text = builtins.toJSON {
    mcpServers = {
      "telegram-mcp" = {
        command = "${telegram-mcp-pkg}/bin/telegram-mcp";
        args = [ "serve" ];
      };
    };
  };
}
```

---

## Automated Updates

This repository comes with an automated update script (`update.py`) that queries PyPI, npm, and GitHub APIs daily via GitHub Actions. It automatically checks for new versions of the MCP servers, updates version tags, prefetches the new content hashes, and commits the updates.

### Run Updater Locally
To check and apply updates:
```bash
python3 update.py
```

### Adding New Packages to `update.py`
If you add a new package to `flake.nix`, register its metadata (update type: npm, pypi, or github) inside the `PACKAGES` dictionary in `update.py`.
