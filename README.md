# maxpkgs

A collection of nix packages and modules I commonly use that aren't always available or up to date in other sources.

## Packages

- Bitwig Studio 6.0.3
- Overwitch
- Amplocker

## Usage

Simply add this library as a flake input:

```nix
inputs = {
  maxpkgs.url = "github:9Prestidigitator/maxpkgs";
}
```

You can then apply an overlay.

```nix
nixpkgs.overlays = [ inputs.maxpkgs.overlays.default ];
```

To use the derivations via `pkgs`.

```nix
environment.systemPackages = with pkgs; [
  bitwig6
  overwitch
  amplocker
];
```

You can also reference packages directly via `nix` cli.

- `nix run github:9Prestidigitator/maxpkgs#bitwig6`
- `nix run github:9Prestidigitator/maxpkgs#overwitch`
- `nix run github:9Prestidigitator/maxpkgs#amplocker`

Or as direct package references.

```nix
environment.systemPackages = with pkgs; [
  inputs.maxpkgs.packages.${system}.bitwig6
  inputs.maxpkgs.packages.${system}.overwitch
  inputs.maxpkgs.packages.${system}.amplocker
];
```

## Inspirations

- [audio.nix](https://github.com/polygon/audio.nix)
- [nix-gaming](https://github.com/fufexan/nix-gaming)
