{
  flake.overlays.default = final: prev: let
    packages = import ../lib/package-platforms.nix {
      pkgs = final;
      filterByPlatform = false;
    };
  in
    removeAttrs packages ["rubberband"]
    // {rubberband-lv2 = packages.rubberband;};
}
