# Nix Model Context Protocol (MCP) Servers Flake

A Nix Flake repository providing Nix-native packages and builders for various Model Context Protocol (MCP) servers.

This flake allows you to run MCP servers hermetically and declaratively in NixOS or Home Manager configurations without needing global installations of `npm` or `pip`.

## Available Packages

*   **`ssh-mcp`**: Remote execution over SSH for MCP clients.
*   **`codebase-memory-mcp`**: High-performance local codebase indexing and memory search.
*   **`google-colab-mcp`**: Run code cells and manage Google Colab notebooks directly from your AI agent.
*   **`telegram-mcp`**: Direct personal account access using MTProto (Telethon), equipped with a Python-based wrapper to ensure daemon background processes spawn correctly without `-c` wrapper errors.
*   **`github-mcp-server`**: Direct integration with GitHub's APIs for managing issues, pull requests, repositories, and more.

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

This repository comes with an automated update script (`update.py`) that queries PyPI, npm, and GitHub APIs to check for new versions of the MCP servers, automatically updates version tags, prefetches the new content hashes, and commits the updates.

### Run Updater
To check and apply updates:
```bash
python3 update.py
```

### Adding New Packages to `update.py`
If you add a new package to `flake.nix`, simply register its name, update type (npm, pypi, or github), and the path to its Nix derivation file inside the `PACKAGES` dictionary in `update.py`.
