{inputs, ...}: {
  perSystem = {system, ...}: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages = import ../lib/package-platforms.nix {inherit inputs pkgs;};

    formatter = pkgs.alejandra;
  };
}
