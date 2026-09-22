{ host, pkgs, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  # Colors for output
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..."
    exit 1
  fi

  if [ -f "$HOME/NixOS/flake.nix" ]; then
    flake=$HOME/NixOS
  elif [ -f "/etc/nixos/flake.nix" ]; then
    flake=/etc/nixos
  else
    echo "Error: flake not found. ensure flake.nix exists in either $HOME/NixOS or /etc/nixos"
    exit 1
  fi
  echo -e "''${GREEN}Flake: $flake''${NC}"
  echo -e "''${GREEN}Host: ${host}''${NC}"
  currentUser=$(logname)

  # replace username variable in variables.nix with $USER
  sudo sed -i -e "s/username = \".*\"/username = \"$currentUser\"/" "$flake/hosts/${host}/variables.nix"

  # Regenerate hardware-configuration.nix into a TEMP file and vet it before
  # installing it.
  #
  # Why: nixos-generate-config writes out whatever is mounted RIGHT NOW. A
  # running container contributes transient overlay/tmpfs mounts named after
  # its container id and layer hashes. Captured into fileSystems they become
  # permanent and REQUIRED; on the next boot the container is gone, the
  # overlay mount fails, and one failed fileSystems entry takes
  # local-fs.target with it -- that is emergency mode, not a login prompt.
  #
  # This cost two bricked boots on 2026-09-22 (podman container running
  # during a rebuild). Checking the generated OUTPUT rather than the mount
  # table means no false alarms from harmless mounts that never get
  # captured -- it only refuses when the damage is actually present.
  hwTmp=$(mktemp)
  trap 'rm -f "$hwTmp"' EXIT

  if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    cat "/etc/nixos/hardware-configuration.nix" >"$hwTmp"
  else
    sudo nixos-generate-config --show-hardware-config >"$hwTmp"
  fi

  if grep -qE 'containers/storage|/var/lib/docker/' "$hwTmp"; then
    echo -e "''${RED}ABORTED: container mounts leaked into hardware-configuration.nix''${NC}"
    echo
    echo "Offending entries:"
    grep -E 'fileSystems.*(containers/storage|/var/lib/docker/)' "$hwTmp" | sed 's/^/  /'
    echo
    echo "Installing this would break your NEXT boot (emergency mode)."
    echo "Stop your containers first, then re-run:"
    echo "  sudo systemctl stop podman-<name>     # podman / oci-containers"
    echo "  docker stop \$(docker ps -q)           # docker / coder workspaces"
    echo
    echo "Verify with:  mount | grep -c containers/storage"
    exit 1
  fi

  sudo cp "$hwTmp" "$flake/hosts/${host}/hardware-configuration.nix"

  sudo git -C "$flake" add hosts/${host}/hardware-configuration.nix

  # nh os switch --hostname "${host}"
  sudo nixos-rebuild switch --flake "$flake#${host}"

  echo
  read -rsn1 -p"$(echo -e "''${GREEN}Press any key to continue''${NC}")"
''
