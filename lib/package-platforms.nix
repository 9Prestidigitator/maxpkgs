{pkgs}: let
  inherit (pkgs) lib callPackage;
  availableOn = systems:
    lib.elem pkgs.stdenv.hostPlatform.system systems;
  pianoteqPackages = callPackage ../pkgs/pianoteq.nix {};
in
  {}
  // lib.optionalAttrs (availableOn ["x86_64-linux"]) {
    amplocker = callPackage ../pkgs/amplocker.nix {};
    bitwig6 = callPackage ../pkgs/bitwig6.nix {};
    eden = callPackage ../pkgs/eden.nix {};
    gvst = callPackage ../pkgs/gvst.nix {};
    js-inflator = callPackage ../pkgs/js-inflator.nix {};
    overwitch = callPackage ../pkgs/overwitch.nix {};
    neural-amp-modeler-lv2 = callPackage ../pkgs/neural-amp-modeler-lv2.nix {};
    pianoteq = pianoteqPackages."standard-trial_9";
    pianoteq-standard = pianoteqPackages.standard_9;
    pianoteq-stage = pianoteqPackages.stage_9;
    pianoteq-trial = pianoteqPackages."standard-trial_9";
    rubberband = callPackage ../pkgs/rubberband.nix {};
    libonnxruntime-neuralnote = callPackage ../pkgs/neuralnote/libonnxruntime-neuralnote.nix {};
    neuralnote = callPackage ../pkgs/neuralnote/neuralnote.nix {};
  }
  // lib.optionalAttrs (availableOn ["aarch64-linux"]) {
    overwitch = callPackage ../pkgs/overwitch.nix {};
    eden = callPackage ../pkgs/eden.nix {};
  }
  // lib.optionalAttrs (availableOn ["aarch64-darwin"]) {}
