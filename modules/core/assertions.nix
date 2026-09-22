# Configuration invariants, enforced at EVALUATION time.
#
# Why an assertion rather than a check in modules/scripts/rebuild.nix: an
# assertion fails `nixos-rebuild`, `nix build` AND `nix flake check` alike, so
# it holds on every path into this configuration -- the local rebuild script,
# CI, and any future pull-mode deployer. A shell check only protects the
# machine that runs the shell script.
#
# Empirically, nothing else in the Nix toolchain catches the case below. On
# the exact configuration that broke this machine on 2026-09-22, all of these
# reported success:
#
#   nix flake check                          -> all checks passed, exit 0
#   nix build ...system.build.toplevel       -> built fine, exit 0
#   nixos-rebuild build-vm                   -> blind to it; qemu-vm.nix
#                                               replaces fileSystems wholesale
#
# They all validate evaluation, build or activation. The failure was at mount
# time during boot, which is below all of them.
{ config, lib, ... }:
let
  inherit (lib)
    attrNames
    filter
    hasInfix
    hasPrefix
    concatStringsSep
    ;

  # Transient container mounts must never be declared as system filesystems.
  # nixos-generate-config writes out whatever is mounted when it runs, so a
  # container running at that moment contributes overlay/tmpfs mounts named
  # after its container id and layer hashes. Those names do not exist on the
  # next boot: the mount fails, local-fs.target fails with it, and the machine
  # lands in emergency mode rather than at a login prompt.
  containerMounts = filter (
    mp: hasInfix "containers/storage" mp || hasPrefix "/var/lib/docker/" mp
  ) (attrNames config.fileSystems);
in
{
  assertions = [
    {
      assertion = containerMounts == [ ];
      message = ''
        Transient container mounts are declared as system filesystems:

        ${concatStringsSep "\n" (map (m: "  - ${m}") containerMounts)}

        These were almost certainly captured by nixos-generate-config while a
        container was running. They do not exist at boot, the mount fails, and
        local-fs.target fails with it -- emergency mode, not a login prompt.

        Remove them from hardware-configuration.nix. modules/scripts/rebuild.nix
        refuses to install a hardware config containing them, so this assertion
        firing means one reached the repository by some other route.
      '';
    }
  ];
}
