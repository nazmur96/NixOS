{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    keepassxc
    # Reads and repairs UEFI boot entries. This host has no second OS to fall
    # back on, so a broken entry must be fixable from a rescue shell -- which
    # means the tool has to be installed already, not fetched later.
    efibootmgr
    # obsidian
    # ludusavi
    # godot
    # proton-vpn
    # github-desktop
    # pokego # Overlayed
  ];
}
