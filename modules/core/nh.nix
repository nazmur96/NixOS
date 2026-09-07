{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) username;
in
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 3d --keep 5";
    };
    flake = "/home/${username}/NixOS";
  };

  # environment.systemPackages = with pkgs; [
  #   nix-output-monitor
  #   nvd
  # ];
}
