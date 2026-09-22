# What happens when the battery hits the critical threshold.
#
# Passed to batterynotify.nix as --execute. The top bar is hidden by default
# on this machine, so a notification alone is exactly what already failed:
# the laptop reached 2% and powered off unannounced. This locks the screen,
# which cannot be missed and stops work, then suspends if the charger still
# has not appeared.
#
# Plugging in cancels the SUSPEND. It deliberately does not unlock the
# screen -- auto-unlocking would mean anyone with physical access could
# bypass the lock screen by plugging in a charger. Type the password.
{ pkgs, ... }:
pkgs.writeShellScriptBin "battery-critical" ''
  set -uo pipefail

  GRACE=''${BATTERY_CRITICAL_GRACE:-60}   # seconds to plug in before suspend
  DRY=''${BATTERY_CRITICAL_DRY_RUN:-0}    # 1 = log only, do not lock/suspend

  log() { echo "[battery-critical] $*" >&2; }

  # Read straight from sysfs rather than upower: this must work even if the
  # daemon is the thing that has gone wrong.
  on_ac() {
    local s
    for s in /sys/class/power_supply/A{C,DP}*/online; do
      [ -r "$s" ] && [ "$(cat "$s")" = "1" ] && return 0
    done
    return 1
  }

  capacity() { cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; }

  # DRY is checked before anything else so the flow stays testable while
  # plugged in -- a dry run you can only exercise on a dying battery is no
  # use. In dry mode every branch below still runs for real; only the two
  # irreversible actions, locking and suspending, are replaced by a log line.
  if [ "$DRY" = "1" ]; then
    log "DRY RUN (grace=''${GRACE}s, battery=$(capacity)%, on_ac=$(on_ac && echo yes || echo no))"
  fi

  if on_ac; then
    log "charger already connected at $(capacity)% -- nothing to do"
    exit 0
  fi

  if [ "$DRY" = "1" ]; then
    log "would lock the screen now"
  else
    log "battery at $(capacity)% -- locking"
    # Backgrounded: hyprlock blocks until unlocked, and the grace countdown
    # has to keep running underneath it.
    ${pkgs.hyprlock}/bin/hyprlock &
  fi

  waited=0
  while [ "$waited" -lt "$GRACE" ]; do
    if on_ac; then
      log "charger connected after ''${waited}s -- suspend cancelled (screen stays locked)"
      exit 0
    fi
    sleep 1
    waited=$((waited + 1))
  done

  if [ "$DRY" = "1" ]; then
    log "would suspend now (still on battery at $(capacity)% after ''${GRACE}s)"
    exit 0
  fi

  log "still on battery at $(capacity)% after ''${GRACE}s -- suspending"
  exec ${pkgs.systemd}/bin/systemctl suspend
''
