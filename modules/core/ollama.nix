# Drop-in for Sly-Harvey/NixOS: modules/core/ollama.nix
#
# Not present in Sly-Harvey's config at all. Bound to loopback only -- an
# unauthenticated model server must never be reachable off the machine.
_: {
  services.ollama = {
    enable = true;
    host = "127.0.0.1";
    port = 11434;
  };
}
