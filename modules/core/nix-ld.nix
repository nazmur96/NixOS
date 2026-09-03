# General support for foreign (non-NixOS-packaged) dynamically-linked
# binaries -- vendor AppImages and similar, which expect the loader at
# /lib64/ld-linux-x86-64.so.2 that NixOS otherwise doesn't have.
#
# Claude Code no longer needs this: it's installed via claude-code-nix (see
# claude-code.nix), a real Nix derivation with no foreign loader to satisfy.
{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      libsecret # keyring access
    ];
  };
}
