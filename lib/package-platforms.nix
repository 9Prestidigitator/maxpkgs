{
  pkgs,
  inputs,
  filterByPlatform ? true,
}: let
  inherit (pkgs) lib callPackage;
  system = pkgs.stdenv.hostPlatform.system;

  withPassthru = package: passthru:
    package.overrideAttrs (oldAttrs: {
      passthru = (oldAttrs.passthru or {}) // passthru;
    });

  auburnSoundsPackages = callPackage ../pkgs/auburn-sounds.nix {};
  auburnSounds = withPassthru auburnSoundsPackages.default auburnSoundsPackages;
  innerPitchPackages = auburnSoundsPackages.inner-pitch;
  innerPitch = withPassthru innerPitchPackages.default innerPitchPackages;
  minimetersPackages = callPackage ../pkgs/minimeters.nix {};
  minimeters = withPassthru minimetersPackages.default minimetersPackages;
  pianoteqPackages = callPackage ../pkgs/pianoteq.nix {};
  pianoteq = withPassthru pianoteqPackages.default pianoteqPackages;
  spleeterpp = callPackage ../pkgs/spleeterpp.nix {};

  winePackages = import ./patches/wine.nix {inherit pkgs;};

  allPackages =
    {
      inherit (winePackages) wineStagingPatched yabridgePatched yabridgectlPatched;

      inherit minimeters pianoteq spleeterpp;

      amplocker = callPackage ../pkgs/amplocker.nix {};
      audiogridder = callPackage ../pkgs/audiogridder.nix {};
      auburn-sounds = auburnSounds;
      auburn-sounds-couture = withPassthru auburnSoundsPackages.couture.default auburnSoundsPackages.couture;
      auburn-sounds-free = auburnSoundsPackages.free;
      auburn-sounds-full = auburnSoundsPackages.full;
      auburn-sounds-graillon = withPassthru auburnSoundsPackages.graillon.default auburnSoundsPackages.graillon;
      auburn-sounds-inner-pitch = innerPitch;
      auburn-sounds-lens = withPassthru auburnSoundsPackages.lens.default auburnSoundsPackages.lens;
      auburn-sounds-panagement = withPassthru auburnSoundsPackages.panagement.default auburnSoundsPackages.panagement;
      auburn-sounds-renegate = withPassthru auburnSoundsPackages.renegate.default auburnSoundsPackages.renegate;
      auburn-sounds-selene = withPassthru auburnSoundsPackages.selene.default auburnSoundsPackages.selene;
      bitwig6 = callPackage ../pkgs/bitwig6.nix {};
      chow-tape-model = callPackage ../pkgs/chow-tape-model.nix {};
      drumlocker = callPackage ../pkgs/drumlocker.nix {};
      gvst = callPackage ../pkgs/gvst.nix {};
      ildaeil = callPackage ../pkgs/ildaeil.nix {};
      inner-pitch = innerPitch;
      inner-pitch-free = innerPitchPackages.free;
      inner-pitch-full = innerPitchPackages.full;
      js-inflator = callPackage ../pkgs/js-inflator.nix {};
      libonnxruntime-neuralnote = callPackage ../pkgs/neuralnote/libonnxruntime-neuralnote.nix {};
      minimeters-demo = minimetersPackages.demo;
      minimeters-full = minimetersPackages.full;
      melissa = callPackage ../pkgs/melissa.nix {inherit spleeterpp;};
      mixlocker = callPackage ../pkgs/mixlocker.nix {};
      mt-power-drumkit-2 = callPackage ../pkgs/mt-power-drumkit-2.nix {};
      neural-amp-modeler-lv2 = callPackage ../pkgs/neural-amp-modeler-lv2.nix {};
      neuralnote = callPackage ../pkgs/neuralnote/neuralnote.nix {};
      overwitch = callPackage ../pkgs/overwitch.nix {};
      pianoteq-standard = pianoteqPackages.standard;
      pianoteq-stage = pianoteqPackages.stage;
      pianoteq-trial = pianoteqPackages.trial;
      rubberband = callPackage ../pkgs/rubberband.nix {};
      spice-oss = callPackage ../pkgs/spice-oss.nix {};
      ultimate-vocal-remover-gui = callPackage ../pkgs/ultimate-vocal-remover-gui.nix {};
    }
    // lib.optionalAttrs (lib.hasAttr system inputs.pulse-visualizer.packages) {
      pulse-visualizer = inputs.pulse-visualizer.packages.${system}.default;
    };

  availablePackages =
    lib.filterAttrs
    (_: package: lib.meta.availableOn pkgs.stdenv.hostPlatform package)
    allPackages;
in
  if filterByPlatform
  then availablePackages
  else allPackages
