{pkgs}: let
  inherit (pkgs) lib callPackage;
  availableOn = systems:
    lib.elem pkgs.stdenv.hostPlatform.system systems;
in
  {}
  // lib.optionalAttrs (availableOn ["x86_64-linux"]) {
    amplocker = callPackage ../pkgs/amplocker.nix {};
    bitwig6 = callPackage ../pkgs/bitwig6.nix {};
    eden = callPackage ../pkgs/eden.nix {};
    overwitch = callPackage ../pkgs/overwitch.nix {};
  }
  // lib.optionalAttrs (availableOn ["aarch64-linux"]) {
    overwitch = callPackage ../pkgs/overwitch.nix {};
    eden = callPackage ../pkgs/eden.nix {};
  }
  // lib.optionalAttrs (availableOn ["aarch64-darwin"]) {}
