{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    pulse-visualizer.url = "github:Audio-Solutions/pulse-visualizer";

    nixpkgs-qtwebkit.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
