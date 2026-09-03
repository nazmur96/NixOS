# Vivaldi is Chromium-based, so it doesn't fit the Firefox-derivative
# home-manager pattern the other browser modules (firefox/zen-beta/floorp)
# use -- no policies.nix/search.nix/settings.nix here, just the package and
# the default-app association.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.vivaldi ];

  home-manager.sharedModules = [
    (_: {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "vivaldi-stable.desktop";
          "x-scheme-handler/http" = "vivaldi-stable.desktop";
          "x-scheme-handler/https" = "vivaldi-stable.desktop";
        };
      };
    })
  ];
}
