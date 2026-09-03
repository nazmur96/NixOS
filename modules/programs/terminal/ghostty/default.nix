{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.ghostty ];

  home-manager.sharedModules = [
    (_: {
      xdg.configFile."ghostty/config".text = ''
        theme = TokyoNight
        font-family = JetBrainsMono Nerd Font
        font-size = 11
        window-padding-x = 8
        window-padding-y = 8
        cursor-style = block
        confirm-close-surface = false
        window-decoration = false
        scrollback-limit = 10000000
      '';
    })
  ];
}
