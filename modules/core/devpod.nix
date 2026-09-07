# DevPod and the devcontainer CLI.
#
# This is Layer 3 of the blueprint (dev environments), deliberately kept in its
# own module rather than folded into virtualisation.nix, because it is a
# different layer with a different owner. Neither tool isolates anything by
# itself: they read a devcontainer.json and drive a PROVIDER -- podman here --
# which is what actually enforces the namespaces and cgroups.
#
# The project toolchains themselves belong in the dev container's image, never
# on this host. If a language runtime ends up in a host module, that is the
# smell the blueprint's Layer 1 rule exists to catch.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    devpod # orchestrates dev environments across providers (podman/ssh/k8s)
    devcontainer # reference CLI; useful for validating a devcontainer.json
  ];
}
