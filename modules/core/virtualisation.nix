{
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) username;
in
{
  # Docker and Podman run side by side on purpose. Docker keeps the existing
  # compose stacks (linkwarden, agent-brain, KiroCrew) working untouched while
  # Podman takes new dev-container work rootlessly. This is a MIGRATION STATE,
  # not the destination: the blueprint gives the container-runtime layer to
  # Podman alone. When the last compose stack has moved over, set
  # docker.enable = false and podman.dockerCompat = true -- `docker` then
  # aliases to rootless Podman, so existing habits and compose files still work.
  #
  # The upstream "only one or the other" comment was imprecise. NixOS asserts
  # exactly two overlaps (nixos/modules/virtualisation/podman/default.nix):
  #   dockerCompat        -> !docker.enable   (both would own the `docker` command)
  #   dockerSocket.enable -> !docker.enable   (only one can serve the socket)
  # Running both engines is otherwise supported.
  virtualisation = {
    spiceUSBRedirection.enable = true;

    # Writes /etc/containers/{policy.json,registries.conf,storage.conf}.
    # Podman refuses to pull an image without policy.json, and podman.enable
    # does NOT imply this option -- verified against the module source.
    containers.enable = true;

    docker = {
      enable = true;
    };

    podman = {
      enable = true;
      dockerCompat = false; # asserted against docker.enable, see above
      dockerSocket.enable = false; # ditto
    };

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
      hooks.qemu = {
        "passthrough" = lib.getExe (
          pkgs.writeShellApplication {
            name = "qemu-hook";

            runtimeInputs = with pkgs; [
              libvirt
              systemd
              kmod
            ];

            text = ''
              GUEST_NAME="$1"
              OPERATION="$2"

              if [ "$GUEST_NAME" != "win11-passthrough" ]; then
                exit 0;
              fi

              if [ "$OPERATION" == "prepare" ]; then
                systemctl stop display-manager.service
                modprobe -r -a nvidia_drm nvidia_uvm nvidia_modeset nvidia
                virsh nodedev-detach pci_0000_01_00_0
                modprobe vfio-pci
              fi

              if [ "$OPERATION" == "release" ]; then
                virsh nodedev-reattach pci_0000_01_00_0
                modprobe -a nvidia nvidia_modeset nvidia_uvm nvidia_drm
                systemctl start display-manager.service
              fi
            '';
          }
        );
      };
    };

    virtualbox.host = {
      enable = false;
      enableExtensionPack = true;
    };
  };

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
  };

  programs = {
    virt-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    virt-viewer # View Virtual Machines
    spice
    spice-gtk
    spice-protocol
    spice-vdagent
    virtio-win
    win-spice

    lazydocker
    docker-client

    # Podman-side equivalents. podman-compose reads the same compose files
    # Docker does, which is what makes a stack-by-stack migration possible.
    podman-compose
    podman-tui
  ];

  # Rootless Podman maps container UIDs into a subordinate range on the host;
  # without entries in /etc/sub{u,g}id rootless containers fail to start.
  # autoSubUidGidRange defaults to false and neither the podman nor the
  # containers module sets it (only incus.nix does), so it is declared here,
  # next to the thing that needs it.
  users.users.${username}.autoSubUidGidRange = true;
}
