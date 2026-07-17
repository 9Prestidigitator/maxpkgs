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

  availablePackages =
    lib.filterAttrs
    (_: package: lib.meta.availableOn pkgs.stdenv.hostPlatform package)
    allPackages;

  qtwebkitOverlay = final: prev: let
    patchedQt5 = prev.qt5.overrideScope (
      qtFinal: qtPrev: {
        qtwebkit = qtPrev.qtwebkit.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or []) ++ [../patches/qtwebkit-ruby32.patch];
        });
      }
    );
  in {
    qt5 = patchedQt5;
    libsForQt5 = patchedQt5;
  };

  qtwebkitPkgs = import inputs.nixpkgs-qtwebkit {
    inherit system;

    overlays = [qtwebkitOverlay];

    config = {
      allowUnfree = true;
      permittedInsecurePackages = ["qtwebkit-5.212.0-alpha4"];
    };
  };

  pyqt5WithQtWebKit =
    qtwebkitPkgs.python3Packages."pyqt5-webkit"
  or qtwebkitPkgs.python3Packages.pyqt5_with_qtwebkit;

  legacyCarla = qtwebkitPkgs.carla.overrideAttrs (oldAttrs: {
    pythonPath =
      oldAttrs.pythonPath
      ++ [pyqt5WithQtWebKit];
  });

  carla = import ../pkgs/carla.nix {
    upstreamCarla = legacyCarla;
    which = qtwebkitPkgs.which;
  };

  allPackages =
    {
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
      inherit carla;
      chow-tape-model = callPackage ../pkgs/chow-tape-model.nix {};
      drumlocker = callPackage ../pkgs/drumlocker.nix {};
      gvst = callPackage ../pkgs/gvst.nix {};
      ildaeil = callPackage ../pkgs/ildaeil.nix {};
      inner-pitch = innerPitch;
      inner-pitch-free = innerPitchPackages.free;
      inner-pitch-full = innerPitchPackages.full;
      js-inflator = callPackage ../pkgs/js-inflator.nix {};
      libonnxruntime-neuralnote = callPackage ../pkgs/neuralnote/libonnxruntime-neuralnote.nix {};
      inherit minimeters;
      minimeters-demo = minimetersPackages.demo;
      minimeters-full = minimetersPackages.full;
      melissa = callPackage ../pkgs/melissa.nix {inherit spleeterpp;};
      mixlocker = callPackage ../pkgs/mixlocker.nix {};
      mt-power-drumkit-2 = callPackage ../pkgs/mt-power-drumkit-2.nix {};
      neural-amp-modeler-lv2 = callPackage ../pkgs/neural-amp-modeler-lv2.nix {};
      neuralnote = callPackage ../pkgs/neuralnote/neuralnote.nix {};
      overwitch = callPackage ../pkgs/overwitch.nix {};
      inherit pianoteq;
      pianoteq-standard = pianoteqPackages.standard;
      pianoteq-stage = pianoteqPackages.stage;
      pianoteq-trial = pianoteqPackages.trial;
      rubberband = callPackage ../pkgs/rubberband.nix {};
      spice-oss = callPackage ../pkgs/spice-oss.nix {};
      ultimate-vocal-remover-gui = callPackage ../pkgs/ultimate-vocal-remover-gui.nix {};
      inherit spleeterpp;
    }
    // lib.optionalAttrs (lib.hasAttr system inputs.pulse-visualizer.packages) {
      pulse-visualizer = inputs.pulse-visualizer.packages.${system}.default;
    };
in
  if filterByPlatform
  then availablePackages
  else allPackages
