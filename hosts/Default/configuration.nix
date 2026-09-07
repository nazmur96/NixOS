{ ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix

    # Core Modules (Be careful here)
    ../../modules/scripts
    ../../modules/core/boot.nix
    ../../modules/core/bash.nix
    ../../modules/core/zsh.nix
    ../../modules/core/starship.nix
    ../../modules/core/fonts.nix
    ../../modules/core/hardware.nix
    ../../modules/core/network.nix
    ../../modules/core/dns.nix
    ../../modules/core/tailscale.nix # private network; stable names via MagicDNS, TLS without a domain
    ../../modules/core/nh.nix
    ../../modules/core/packages.nix
    ../../modules/core/printing.nix
    ../../modules/core/sddm.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    # ../../modules/core/syncthing.nix
    # ../../modules/core/jellyfin.nix
    # ../../modules/core/dlna.nix
    # ../../modules/core/flatpak.nix
    ../../modules/core/virtualisation.nix # docker + rootless podman + libvirtd
    ../../modules/core/devpod.nix # dev-environment orchestration, drives podman
    ../../modules/core/mise.nix # non-Nix toolchain manager, kept for portable skills
    ../../modules/core/nix-ld.nix # foreign-binary loader, for Orca and similar AppImages
    ../../modules/core/appimages.nix # binfmt registration so AppImages run by path
    ../../modules/core/ollama.nix # loopback-only, not exposed off the machine
    ../../modules/core/claude-code.nix

    # Optional
    # ../../modules/hardware/drives # My personal drives
    ../../modules/hardware/video/${vars.videoDriver}.nix
    ../../modules/desktop/${vars.desktop}
    ../../modules/programs/browser/${vars.browser}
    ../../modules/programs/terminal/${vars.terminal}
    ../../modules/programs/editor/${vars.editor} # terminal editor; also sets $EDITOR (see modules/core/users.nix)
    ../../modules/programs/editor/vscode # GUI editor. Imported explicitly, NOT via vars.editor, because
    # setting vars.editor = "vscode" would make $EDITOR="code" -- and `code`
    # returns immediately without --wait, so git would see an empty commit
    # message every time. Terminal editing stays nvim; VS Code is the GUI and
    # the client half of the DevPod/Remote-SSH split (UI here, LSPs in the
    # container).
    ../../modules/programs/file-manager/${vars.fileManager}
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/gh-dash
    ../../modules/programs/cli/btop
    # ../../modules/programs/cli/cava
    # ../../modules/programs/cli/fastfetch
    # ../../modules/programs/media/discord
    # ../../modules/programs/media/spicetify
    # ../../modules/programs/media/youtube-music
    # ../../modules/programs/media/thunderbird
    # ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/tlp
    # ../../modules/programs/misc/lact # GPU fan, clock and power configuration
  ];
}
