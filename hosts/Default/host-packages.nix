{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    keepassxc
    # npx ships bundled with npm/nodejs.
    nodejs
    pnpm
    bun
    # Reads and repairs UEFI boot entries. This host has no second OS to fall
    # back on, so a broken entry must be fixable from a rescue shell -- which
    # means the tool has to be installed already, not fetched later.
    efibootmgr
    herdr # Terminal workspace/session multiplexer for AI coding agents
    pi-coding-agent # Earendil's "pi" AI coding agent CLI
    # obsidian
    # ludusavi
    # godot
    # proton-vpn
    # github-desktop
    # pokego # Overlayed
  ];
}
