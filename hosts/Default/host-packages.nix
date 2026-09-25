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
    # Cursor's agentic CLI. Binary is `cursor-agent`, not `cursor-cli` -- the
    # attribute and the command differ, which is worth remembering at the
    # prompt. Same host-layer rationale as Claude Code: an agent CLI drives
    # whichever repo you point it at, so it is not project-specific and does
    # not belong in a dev container.
    #
    # nixpkgs packages the raw release tarball, so unlike the vendor
    # install.sh there is no bundled updater keeping its own copies under
    # ~/.local/share -- which is what left three shadowing Claude Codes on
    # PATH. Two subcommands still reach outside the store, though:
    #   `cursor-agent update` tries to overwrite the read-only store path and
    #   fails loudly; update via a nixpkgs bump instead.
    #   `install-shell-integration` edits ~/.zshrc, which home-manager owns
    #   and will overwrite. Don't run it.
    #
    # Pinned to the 2026-08-11 snapshot by our nixpkgs lock, not by upstream.
    cursor-cli
    # Grok Bot -- SpaceXAI/Cursor's desktop agent. Not in nixpkgs; repacked
    # from the vendor .deb in pkgs/grok-bot.nix (overlayed). Installed this
    # way rather than the .deb so it has one store-managed copy and no apt
    # source or self-registered updater. Beta access needs Cursor Ultra /
    # Teams Premium / SuperGrok Heavy -- the app installs regardless.
    grok-bot
    # OpenSpec -- spec-driven development for AI agents (proposal/specs/
    # design/tasks per change, under openspec/ in each repo). Host layer for
    # the same reason as cursor-cli: it drives agents across every repo, it
    # is not one project's dependency. Per-repo setup is
    # `openspec init --tools claude,cursor`, committed with the repo.
    # Upgrade via a nixpkgs bump, not `npm install -g`, which would shadow it.
    openspec
    # obsidian
    # ludusavi
    # godot
    # proton-vpn
    # github-desktop
    # pokego # Overlayed
  ];

  # OpenSpec phones home with command names and version by default. The env
  # var overrides its global config, so this stays off even if something
  # runs `openspec config set telemetry.enabled true`.
  environment.variables.OPENSPEC_TELEMETRY = "0";
}
