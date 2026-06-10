{
  pkgs,
  filterByPlatform ? true,
}: let
  inherit (pkgs) lib callPackage;
  innerPitchPackages = callPackage ../pkgs/inner-pitch.nix {};
  innerPitch = innerPitchPackages.default.overrideAttrs (oldAttrs: {
    passthru = (oldAttrs.passthru or {}) // innerPitchPackages;
  });
  pianoteqPackages = callPackage ../pkgs/pianoteq.nix {};
  pianoteq = pianoteqPackages.default.overrideAttrs (oldAttrs: {
    passthru = (oldAttrs.passthru or {}) // pianoteqPackages;
  });
  availablePackages =
    lib.filterAttrs
    (_: package: lib.meta.availableOn pkgs.stdenv.hostPlatform package)
    allPackages;
  allPackages = {
    amplocker = callPackage ../pkgs/amplocker.nix {};
    bitwig6 = callPackage ../pkgs/bitwig6.nix {};
    drumlocker = callPackage ../pkgs/drumlocker.nix {};
    # eden = callPackage ../pkgs/eden.nix {};
    gvst = callPackage ../pkgs/gvst.nix {};
    inner-pitch = innerPitch;
    inner-pitch-free = innerPitchPackages.free;
    inner-pitch-full = innerPitchPackages.full;
    js-inflator = callPackage ../pkgs/js-inflator.nix {};
    libonnxruntime-neuralnote = callPackage ../pkgs/neuralnote/libonnxruntime-neuralnote.nix {};
    mt-power-drumkit-2 = callPackage ../pkgs/mt-power-drumkit-2.nix {};
    neural-amp-modeler-lv2 = callPackage ../pkgs/neural-amp-modeler-lv2.nix {};
    neuralnote = callPackage ../pkgs/neuralnote/neuralnote.nix {};
    overwitch = callPackage ../pkgs/overwitch.nix {};
    inherit pianoteq;
    pianoteq-standard = pianoteqPackages.standard;
    pianoteq-stage = pianoteqPackages.stage;
    pianoteq-trial = pianoteqPackages.trial;
    rubberband = callPackage ../pkgs/rubberband.nix {};
  };
in
  if filterByPlatform
  then availablePackages
  else allPackages
