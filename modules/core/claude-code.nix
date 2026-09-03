# Claude Code, via sadjow/claude-code-nix rather than the vendor installer.
#
# The official installer (curl | bash) ships a dynamically-linked binary that
# needs nix-ld to find a loader, self-updates outside the Nix store, and isn't
# reproducible from this repo -- a fresh clone of this flake wouldn't bring
# Claude Code back. claude-code-nix repackages each release as a proper
# derivation instead: `nixos-rebuild switch` alone puts a working `claude` on
# PATH, pinned by flake.lock like everything else here. Trade-off: updates
# land only via `nix flake lock --update-input claude-code-nix`, not the
# moment upstream ships one.
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.claude-code-nix.packages.${pkgs.system}.default

    # uvx runs the aws-mcp MCP server. ripgrep/git/gh, which Claude Code also
    # shells out to, are already in modules/core/packages.nix.
    pkgs.uv
  ];
}
