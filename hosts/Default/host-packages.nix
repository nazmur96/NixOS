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
    # Cursor -- AI editor, a VS Code fork. Unfree; allowed by the global
    # allowUnfree in modules/core/packages.nix, so no predicate is needed.
    #
    # Host layer on purpose: this is an editor CLIENT, which ARCHITECTURE.md
    # keeps local for keystroke latency. Its language servers and toolchains
    # belong in the dev container, not here -- same split as VS Code.
    code-cursor
    # obsidian
    # ludusavi
    # godot
    # proton-vpn
    # github-desktop
    # pokego # Overlayed
  ];
}
