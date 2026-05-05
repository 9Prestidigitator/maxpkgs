{
  flake.overlays.default = final: prev: import ../lib/package-platforms.nix {pkgs = final;};
}
