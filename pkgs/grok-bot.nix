# Grok Bot -- SpaceXAI/Cursor's desktop agent. Not in nixpkgs, so this repacks
# the vendor .deb. Its postinst is deliberately NOT replicated: it registers an
# apt source, installs an AppArmor profile and setuids chrome-sandbox, none of
# which apply here (NixOS allows unprivileged user namespaces, which Electron's
# sandbox uses instead).
#
# Updating: read the new Version/SHA256 from
#   https://downloads.cursor.com/aptrepo/dists/grok-bot/main/binary-amd64/Packages
# and bump both below. The pool may drop old versions, so a stale pin fails
# at fetch time rather than silently changing.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libsecret,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  util-linux,
  xdg-utils,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxscrnsaver,
  libxtst,
}:
stdenv.mkDerivation rec {
  pname = "grok-bot";
  version = "0.58.0";

  src = fetchurl {
    url = "https://downloads.cursor.com/aptrepo/pool/grok-bot/g/gr/grok-bot_${version}_amd64.deb";
    sha256 = "47675c405a4def58ce5b61dfcc71b5ba3ffa6a045a3118d8ff9e431ff02f6c9e";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib # libstdc++ for the bundled .node addons
    util-linux # libuuid
    libx11
    libxscrnsaver
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxtst
    libxcb
  ];

  # dlopen()ed at runtime, so autoPatchelf can't see them from the ELF headers.
  runtimeDependencies = [
    (lib.getLib systemd) # libudev
    libGL
  ];

  # We wrap once ourselves, below; stop wrapGAppsHook wrapping a second time.
  dontWrapGApps = true;

  unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    # The vendor path has a space in it; keep store paths boring.
    cp -r "opt/Grok Bot" $out/share/grok-bot
    cp -r usr/share/icons usr/share/applications $out/share/

    substituteInPlace $out/share/applications/grok-bot.desktop \
      --replace-fail "Exec=grok-bot" "Exec=$out/bin/grok-bot"

    runHook postInstall
  '';

  # Native Wayland when the session asks for it (NIXOS_OZONE_WL), same
  # convention as the nixpkgs Electron apps.
  postFixup = ''
    makeWrapper $out/share/grok-bot/grok-bot $out/bin/grok-bot \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  meta = {
    description = "Grok Bot desktop agent (SpaceXAI / Cursor)";
    homepage = "https://cursor.com/grok";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "grok-bot";
  };
}
