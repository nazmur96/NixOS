{
  lib,
  pkgs,
  terminal,
  ...
}:
let
  wallpaperDir = "${../themes/wallpapers}";
  wallpaperThumbs =
    pkgs.runCommand "wallpaper-thumbnails"
      {
        buildInputs = [ pkgs.imagemagick ];
      }
      ''
        mkdir -p $out
        for wallpaper in "${wallpaperDir}"/*.{webp,jxl,jpg,jpeg,png,gif}; do
          if [ -f "$wallpaper" ]; then
            wallpaper_name=$(basename "$wallpaper")
            wallpaper_name="''${wallpaper_name%.*}"
            thumbnail_size="320x180"
            if [ ! -f "$out/''${wallpaper_name}.jpg" ]; then
              magick "$wallpaper[0]" -strip -gravity center -thumbnail "''${thumbnail_size}^" -extent "$thumbnail_size" "$out/''${wallpaper_name}.jpg"
            fi
          fi
        done
      '';
in
pkgs.writeShellScriptBin "launcher" ''
  # check if rofi is already running
  if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
  fi

  case $1 in
  drun)
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-7.rasi"
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-3.rasi"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    r_override="entry{placeholder:'Search Applications...';}listview{lines:9;}"

    rofi -show drun -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  window)
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Windows...';}listview{lines:12;}"

    rofi -show window -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  file)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    r_override="entry{placeholder:'Search Files...';}listview{lines:8;}"

    rofi -show filebrowser -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  tmux)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Tmux Sessions...';}listview{lines:15;}"

    sessions=$(tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' |
      rofi -dmenu -i -theme-str "$r_override" -theme "$rofi_theme" | cut -d: -f1)
    if [[ $sessions ]]; then
      ${terminal} --hold -e tmux attach -t $sessions
    fi
    ;;
  wallpaper)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/wallpaper-select.rasi"
    r_override="entry{placeholder:'Search Wallpapers...';}"
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    # r_override="entry{placeholder:'Search Wallpapers...';}listview{lines:15;}"

    CACHE_DIR=${wallpaperThumbs}
    WALLPAPER_DIR="${wallpaperDir}"

    rofi_cmd() {
      rofi -dmenu \
        -i \
        -theme-str "$r_override" \
        -theme "$rofi_theme"
    }

    CHOICE=$(${lib.getExe pkgs.fd} --type f . "''${WALLPAPER_DIR}" \
      | sed 's/.*\///' \
      | while read -r A ; do echo -en "$A\x00icon\x1f""''${CACHE_DIR}"/"''${A%.*}.jpg\n" ; done \
      | rofi_cmd)
    [ -z "$CHOICE" ] && exit 0

    awww img "$WALLPAPER_DIR/$CHOICE" --transition-step 90 --transition-duration 1 --transition-fps 60 --transition-type wipe
    ;;
  emoji)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Emojis...';}listview{lines:15;}"

    rofi -modi emoji -show emoji -theme "''${rofi_theme}" -theme-str "$r_override"
    ;;
  games)
    r_override="entry{placeholder:'Search Games...';}listview{lines:15;}"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-1/style-5.rasi"

    rofi -show games -modi games -theme "''${rofi_theme}" -theme-str "$r_override"
    ;;
  homelab)
    # One place for the things I actually open: services on management-1,
    # an SSH session, cloud consoles, local apps. Adding an entry is one line.
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    r_override="entry{placeholder:'Homelab...';}listview{lines:12;}"

    # label | kind | target
    #   url = open in the default browser (vivaldi, via xdg-open)
    #   ssh = open a terminal already connected
    #   app = run a local program
    entries() {
      echo "󰋜  Homepage|url|https://management-1.tail8cb9b0.ts.net:3001"
      echo "󰌆  Authentik|url|https://management-1.tail8cb9b0.ts.net:9443"
      echo "  AWS Console (via SSO)|url|https://management-1.tail8cb9b0.ts.net:9443/application/saml/aws/sso/binding/init/"
      echo "󰒋  ssh management-1|ssh|mgmt"
      echo "󰖟  Tailscale admin|url|https://login.tailscale.com/admin/machines"
      echo "󰅟  Hetzner Cloud|url|https://console.hetzner.cloud"
      echo "  homelab repo|url|https://github.com/nazmur96/homelab"
      echo "  NixOS repo|url|https://github.com/nazmur96/NixOS"
      echo "󰃀  Linkwarden|url|https://management-1.tail8cb9b0.ts.net:3002"
      echo "󰯄  Vaultwarden|url|https://management-1.tail8cb9b0.ts.net:3003"
      echo "󰠮  Notion|url|https://www.notion.so"
      echo "󰌾  KeePassXC (break-glass)|app|keepassxc"
      echo "󰘦  Graphiti MCP|url|https://management-1.tail8cb9b0.ts.net:8443"
    }

    CHOICE=$(entries | cut -d'|' -f1 |
      rofi -dmenu -i -theme-str "$r_override" -theme "$rofi_theme")
    [ -z "$CHOICE" ] && exit 0

    LINE=$(entries | grep -m1 -F "$CHOICE|")
    KIND=$(echo "$LINE" | cut -d'|' -f2)
    TARGET=$(echo "$LINE" | cut -d'|' -f3-)

    case "$KIND" in
      url) setsid xdg-open "$TARGET" >/dev/null 2>&1 & ;;
      ssh) setsid ${terminal} -e ssh "$TARGET" >/dev/null 2>&1 & ;;
      app) setsid "$TARGET" >/dev/null 2>&1 & ;;
    esac
    ;;
  help | --help | -h)
    echo "Usage: launcher [ACTION]"
    echo "Launch various rofi modes with custom themes and settings."
    echo ""
    echo "Actions:"
    echo "  drun         Launch application search mode"
    echo "  window       Switch between open windows"
    echo "  file         Browse and search files"
    echo "  tmux         Search active tmux sessions"
    echo "  wallpaper    Search and set wallpapers"
    echo "  emoji        Search and insert emojis"
    echo "  games        Launch games menu"
    echo "  homelab      Open homelab services, SSH sessions and consoles"
    echo "  help         Display this help message"
    echo "  --help       Same as 'help'"
    echo ""
    echo "If no action is specified, defaults to 'drun' mode."
    exit 0
    ;;
  *) exec "$0" drun ;;
  esac
''
