{ host, inputs, ... }:
let
  inherit (import ../hosts/${host}/variables.nix) sddmTheme;
in
{
  # Overlay custom derivations into nixpkgs so you can use pkgs.<name>
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final;
      inherit host;
    };

  # https://wiki.nixos.org/wiki/Overlays
  # pkgs.vscode-marketplace.<publisher>.<name> and pkgs.open-vsx.<...>
  vscode-marketplace = inputs.nix-vscode-extensions.overlays.default;

  modifications = final: prev: {
    nur = inputs.nur.overlays.default;
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
