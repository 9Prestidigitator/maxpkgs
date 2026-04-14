{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {self, nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system} = {
      bitwig-studio6 = pkgs.callPackage ./pkgs/bitwig6.nix {};
      overwitch = pkgs.callPackage ./pkgs/overwitch.nix {};
      amplocker = pkgs.callPackage ./pkgs/amplocker.nix {};
    };
    overlays.default = final: prev: {
      bitwig6 = self.packages.${system}.bitwig-studio6;
      overwitch = self.packages.${system}.overwitch;
      amplocker = self.packages.${system}.amplocker;
    };
  };
}
