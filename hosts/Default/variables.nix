{
  username = "nazmurrakib"; # auto-set with install.sh, live-install.sh, and rebuild scripts.

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, noctalia, wayle
  waybarTheme = "minimal"; # stylish, minimal
  sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "coding-desk.jpeg"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "kurzgesagt-galaxies.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty, wezterm, ghostty
  editor = "nixvim"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim
  browser = "vivaldi"; # zen-beta, firefox, floorp, vivaldi
  fileManager = "thunar"; # yazi, lf, thunar
  shell = "zsh"; # bash, zsh

  # Hardware -- ThinkPad T14 Gen 1 AMD. This config was originally tuned for a
  # different (Intel/Nvidia, desktop) machine; these three were wrong for this
  # laptop and are now corrected.
  hostname = "nixos";
  videoDriver = "amdgpu"; # nvidia, amdgpu, intel -- integrated Radeon Vega (Renoir), confirmed via lspci
  bluetoothSupport = true; # confirmed present: rfkill lists hci0
  batterySupport = true; # it's a laptop

  # Localization
  timezone = "Europe/Warsaw";
  locale = "en_US.UTF-8";
  clock24h = true;
  kbdLayout = "us";
  kbdVariant = "";
  consoleKeymap = "us";
  capslockAsESC = false;
}
