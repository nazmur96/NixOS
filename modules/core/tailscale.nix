# Tailscale: the private network layer.
#
# What it buys us: every machine gets a stable identity and a stable name
# (<hostname>.<tailnet>.ts.net) that follows it across networks. That is the
# prerequisite for hosting anything, because a service's hostname gets baked
# into its config -- an IP address does not survive a DHCP lease or a move.
#
# Layer ownership: Nix owns the daemon and the firewall holes. Tailscale owns
# device identity and the 100.64.0.0/10 address space. It explicitly does NOT
# own DNS on this host -- AdGuard does (see dns.nix), which forwards *.ts.net
# to Tailscale's resolver at 100.100.100.100. Join with `--accept-dns=false`
# so tailscaled never rewrites /etc/resolv.conf. Two daemons writing the same
# file is the same class of bug as two package managers installing Python:
# boot order silently decides the winner, and the loser fails quietly.
#
# Deliberately NOT set: authKeyFile. Joining a tailnet is a one-time manual
# `sudo tailscale up` -- an auth key committed here would be a secret in git,
# and "never auto-reconcile the workstation" covers network membership too.
{ ... }:
{
  services.tailscale = {
    enable = true;

    # "client" = may use exit nodes and accept subnet routes advertised by
    # other machines; advertises nothing itself. Raise to "both" only if this
    # laptop ever needs to BE an exit node or subnet router, which it should
    # not -- that is a server's job.
    useRoutingFeatures = "client";

    # Opens the UDP port for direct peer-to-peer connections. Without it
    # traffic still works but relays through Tailscale's DERP servers:
    # correct, just slower and dependent on their infrastructure.
    openFirewall = true;

    # Lets this non-root user run `tailscale cert` to fetch a real Let's
    # Encrypt certificate for <host>.<tailnet>.ts.net. This is how we get
    # genuine HTTPS without owning a domain -- the thing that unblocks
    # putting an identity provider behind TLS.
    permitCertUid = "nazmurrakib";
  };

  # Traffic arriving over tailscale0 is already authenticated by WireGuard
  # keys before the kernel sees it, so the host firewall does not re-filter it.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
