# Coder server -- the control plane for the "three golden paths" exercise
# (infra-dev / app-dev templates, per-persona workspaces).
#
# Deliberately does NOT put the `coder` CLI in environment.systemPackages --
# that stays an ad-hoc `nix shell nixpkgs#coder --impure -c coder ...`
# invocation on purpose (kept off the interactive PATH; --impure needed
# because the coder derivation wraps in terraform, which is BSL-licensed).
# This module only owns the long-running *server* process, which used to be
# started by hand in a terminal and died with that terminal -- taking every
# workspace agent down with it, and the agent's container along with it
# (the docker template's agent is the container's PID 1, RestartPolicy=no).
#
# Companion fix: modules/core/network.nix trusts docker0 so the workspace
# agent can phone home; without both fixes together workspaces still fail.
{
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) username;
in
{
  systemd.services.coder = {
    description = "Coder server (local dev-environment platform)";
    after = [
      "docker.service"
      "network-online.target"
    ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = username;
      SupplementaryGroups = [ "docker" ];
      WorkingDirectory = "/home/${username}";
      Environment = "HOME=/home/${username}";
      ExecStart = "${pkgs.coder}/bin/coder server --access-url http://172.17.0.1:3000 --http-address 0.0.0.0:3000";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
