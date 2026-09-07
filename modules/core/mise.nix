# mise: the non-Nix, cross-platform toolchain manager.
#
# Here for portability of SKILL, not because this machine needs it -- devenv
# already covers the same job natively. Most workplaces will never adopt Nix;
# mise is what they use instead, and it is the tool worth being fluent in.
#
# Layer ownership: Nix owns this binary. mise owns tool versions ONLY inside
# repos that carry a mise.toml. A repo has a mise.toml OR a devenv.nix, never
# both -- two controllers for one layer is exactly the drift the blueprint
# forbids (see the three-copies-of-claude-code cleanup).
#
# Caveat, deliberately accepted: mise installs prebuilt binaries into
# ~/.local/share/mise, which is imperative state outside the flake. It is
# reconstructible from mise.toml + mise.lock, so it survives the section 9
# wipe test, but it is not Nix-managed. Those foreign, dynamically-linked
# binaries only run here because nix-ld.nix is enabled.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mise
    usage # mise shells out to this for completions; `mise doctor` warns without it
  ];
}
