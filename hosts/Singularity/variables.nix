{
  username = "railgun"; # auto-set with install.sh, live-install.sh, and rebuild scripts.

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "noctalia"; # waybar, noctalia, wayle
  waybarTheme = "minimal"; # stylish, minimal
  sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "evening-sky.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "kurzgesagt-galaxies.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty, wezterm
  editor = "nixvim"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim
  browser = "zen-beta"; # zen-beta, firefox, floorp
  fileManager = "yazi"; # yazi, lf, thunar
  shell = "zsh"; # bash, zsh

  # The gaming MODULE was dropped in 2648af8 and modules/core/games.nix no
  # longer exists. This flag survives because modules/desktop/plasma6 still
  # inherits it to gate a Lutris shortcut -- removing it breaks plasma6.
  games = false;

  # Hardware
  hostname = "Singularity";
  videoDriver = "nvidia"; # nvidia, amdgpu, intel
  nvidiaChannel = "legacy_580"; # stable, latest, beta, legacy_xxx
  bluetoothSupport = false; # Whether your motherboard supports bluetooth
  batterySupport = false; # Whether device has a battery (laptop)

  # Localization
  timezone = "Europe/London";
  locale = "en_GB.UTF-8";
  clock24h = true;
  kbdLayout = "gb";
  kbdVariant = "extd";
  consoleKeymap = "uk";
  capslockAsESC = false;
}
