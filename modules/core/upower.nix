# UPower -- the battery daemon.
#
# Nothing enables this on bare Hyprland; GNOME and Plasma pull it in, a
# standalone compositor does not. Its absence is not cosmetic here:
# modules/desktop/hyprland/scripts/batterynotify.nix watches UPower over
# D-Bus to learn about battery changes, so without the daemon that script
# starts, finds no battery path to monitor, and dies silently. The visible
# symptom was a laptop that gave no warning at all and simply powered off.
#
# The percentages below are also an INDEPENDENT last line of defence. The
# battery script acts at 7%; UPower acts at 3% whether or not that script is
# alive. If it dies again the way it just did, the machine still shuts down
# cleanly rather than having the battery cut out mid-write.
#
# criticalPowerAction is PowerOff, not Hibernate: hardware-configuration.nix
# declares `swapDevices = [ ]`, and hibernate without swap silently does
# nothing -- which would make this failsafe a placebo.
_: {
  services.upower = {
    enable = true;

    # Policy on charge percentage rather than estimated time remaining.
    # Time estimates swing wildly under changing load, so a 7% threshold
    # expressed in minutes fires early, late, or twice.
    usePercentageForPolicy = true;

    percentageLow = 15;
    percentageCritical = 7;
    percentageAction = 3;

    criticalPowerAction = "PowerOff";
  };
}
