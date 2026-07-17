{
  pkgs,
  inputs,
}: let
  system = pkgs.stdenv.hostPlatform.system;

  # Fixes Carla's file picker for plugins such as Neural Amp Modeler.
  qtwebkitOverlay = final: prev: let
    patchedQt5 = prev.qt5.overrideScope (
      qtFinal: qtPrev: {
        qtwebkit = qtPrev.qtwebkit.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or []) ++ [../../patches/qtwebkit-ruby32.patch];
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

  carla = import ../../pkgs/carla.nix {
    upstreamCarla = legacyCarla;
    which = qtwebkitPkgs.which;
  };
in {
  inherit carla;
}
