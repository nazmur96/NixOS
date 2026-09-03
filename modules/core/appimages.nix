# Drop-in for Sly-Harvey/NixOS: modules/core/appimages.nix
#
# Sly-Harvey's modules/core/packages.nix ships `appimage-run`, which works but
# requires you to type it:
#
#     appimage-run ~/AppImages/orca.appimage
#
# The .desktop entry that Orca installed does NOT do that -- it execs the
# AppImage directly:
#
#     Exec=env DESKTOPINTEGRATION=1 /home/nazmurrakib/AppImages/orca.appimage --no-sandbox %U
#
# so clicking Orca in the launcher silently does nothing. binfmt registers
# AppImages with the kernel, which makes direct execution work and leaves the
# existing .desktop file correct as written.
_: {
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
