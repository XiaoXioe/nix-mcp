# modules/nixos/default.nix
# NixOS module for nix-mcp — minimal placeholder
#
# Most MCP servers are user-space tools; install them via the Home Manager module.
# This module exists for forward-compatibility (e.g., future system-level MCP daemons).
{ ... }:
{
  # Currently empty — use homeModules.default for per-user MCP server installation.
  # See: inputs.nix-mcp.homeModules.default
}
