{ pkgs, ... }:
pkgs.writeShellScriptBin "topbar-toggle" ''
  if ${pkgs.procps}/bin/pgrep waybar > /dev/null; then
    ${pkgs.procps}/bin/pkill waybar
  else
    ${pkgs.waybar}/bin/waybar &
    disown
  fi
''
