# maxpkgs

Personal Nix packages, overlay, and small NixOS modules for audio tools I use that are missing from nixpkgs, need newer versions, or need packaging choices that fit my systems.

This repo is Linux-audio heavy. Several packages are proprietary or otherwise unfree, so read the upstream license before using or redistributing anything.

## Packages

All packages are available for the listed platforms. `x86_64-linux` and
`aarch64-linux` mean 64-bit Intel/AMD and ARM Linux, respectively.

| Attribute                                                                      | Version                                                                                         | Platforms                   | Provides                                                         |
| ------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- | --------------------------- | ---------------------------------------------------------------- |
| `amplocker`                                                                    | 1.5.1                                                                                           | x86_64-linux                | Standalone, LV2, VST3                                            |
| `audiogridder`                                                                 | 1.2.0                                                                                           | x86_64-linux                | AudioGridder server and VST3 plug-in                             |
| `auburn-sounds`, `auburn-sounds-free`                                          | Selene 1.1; Graillon 3.2; Inner Pitch 2.1; Lens 1.4; Renegate 1.6; Panagement 2.8; Couture 1.10 | x86_64-linux                | Free CLAP, LV2, VST2, and VST3 suite                             |
| `auburn-sounds-full`                                                           | same as free suite                                                                              | x86_64-linux                | Paid suite; see [Paid Packages](#paid-packages)                  |
| `auburn-sounds-{selene,graillon,inner-pitch,lens,renegate,panagement,couture}` | corresponding suite version                                                                     | x86_64-linux                | Individual free editions; each has `.full`/`.paid`               |
| `bitwig6`                                                                      | 6.1-beta4                                                                                       | x86_64-linux                | Bitwig Studio                                                    |
| `chow-tape-model`                                                              | 2.11.4                                                                                          | x86_64-linux                | Standalone, CLAP, LV2, VST3                                      |
| `drumlocker`                                                                   | 1.0.2                                                                                           | x86_64-linux                | LV2, VST3, and sample-data helper                                |
| `gvst`                                                                         | 2024-09-25                                                                                      | x86_64-linux                | VST2 suite                                                       |
| `ildaeil`                                                                      | unstable-2026-06-23                                                                             | Linux                       | Audio plug-in host                                               |
| `inner-pitch`, `inner-pitch-free`, `inner-pitch-full`                          | 2.1                                                                                             | x86_64-linux                | Auburn Sounds Inner Pitch aliases                                |
| `js-inflator`                                                                  | 2.0.3.2                                                                                         | Linux                       | VST3                                                             |
| `libonnxruntime-neuralnote`                                                    | 1ac0228d5d07890c0a504fbdeb6588e00afe1b8a                                                        | x86_64-linux                | NeuralNote support library                                       |
| `melissa`                                                                      | 4.5.0                                                                                           | x86_64-linux                | Standalone practice player with stem separation                  |
| `minimeters`, `minimeters-demo`                                                | 1.0.30                                                                                          | x86_64-linux, aarch64-linux | Demo standalone, CLAP, VST3                                      |
| `minimeters-full`                                                              | 1.0.30                                                                                          | x86_64-linux, aarch64-linux | Paid standalone, CLAP, VST3; see [Paid Packages](#paid-packages) |
| `mixlocker`                                                                    | 1.0.7                                                                                           | x86_64-linux                | LV2, VST3, and preset/data helper                                |
| `mt-power-drumkit-2`                                                           | 2.1.5.1                                                                                         | x86_64-linux                | VST3                                                             |
| `neural-amp-modeler-lv2`                                                       | v0.2.3                                                                                          | Linux, Darwin               | LV2                                                              |
| `neural-amp-modeler-ui`                                                        | unstable-2026-06-07                                                                             | Linux                       | LV2 with X11 UI                                                  |
| `neuralnote`                                                                   | 1.1.0                                                                                           | x86_64-linux                | Standalone, VST3                                                 |
| `overwitch`                                                                    | 2.2                                                                                             | Linux                       | JACK client and helpers; includes `nixosModules.overwitch`       |
| `pianoteq`, `pianoteq-trial`                                                   | 9.1.2                                                                                           | x86_64-linux, aarch64-linux | Standard trial: standalone, LV2, VST3                            |
| `pianoteq-standard`, `pianoteq-stage`                                          | 9.1.2                                                                                           | x86_64-linux, aarch64-linux | Paid standalone, LV2, VST3; see [Paid Packages](#paid-packages)  |
| `pulse-visualizer`                                                             | 1.3.9-50466f1-flake                                                                             | All                         | Standalone visualizer                                            |
| `rubberband` (`rubberband-lv2` in overlay)                                     | 4.0.0                                                                                           | All                         | Library and audio plug-ins                                       |
| `serum2`                                                                        | 2.1.5-beta                                                                                      | x86_64-linux                | Serum 2 Linux beta VST3                                          |
| `spice-oss`                                                                    | unstable-2026-06-16                                                                             | Linux                       | Standalone, LV2, VST3                                            |
| `spleeterpp`                                                                   | 0.2.1-unstable-2026-06-16                                                                       | x86_64-linux                | Melissa support library                                          |
| `ultimate-vocal-remover-gui`                                                   | 5.6.0                                                                                           | x86_64-linux                | Standalone source-separation GUI                                 |
| `wineStagingPatched`                                                           | 11.12                                                                                           | x86_64-linux, aarch64-linux | Wine staging with the yabridge cursor fix                        |
| `yabridgePatched`, `yabridgectlPatched`                                        | 5.1.1                                                                                           | x86_64-linux                | Windows plug-in bridge and control tool                          |

`neural-amp-modeler-ui` includes the Neural Amp Modeler DSP plugin, so installing `neural-amp-modeler-lv2` alongside it is supported but unnecessary.

## Quick Start

Add the flake input:

```nix
{
  inputs.maxpkgs.url = "github:9Prestidigitator/maxpkgs";
}
```

Use the overlay if you want packages under `pkgs`:

```nix
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [inputs.maxpkgs.overlays.default];

  environment.systemPackages = with pkgs; [
    bitwig6
    minimeters
    auburn-sounds-free
    pianoteq-trial
  ];
}
```

Or reference flake packages directly:

```nix
{
  environment.systemPackages = [
    inputs.maxpkgs.packages.${pkgs.system}.minimeters-demo
    inputs.maxpkgs.packages.${pkgs.system}.neuralnote
  ];
}
```

Useful CLI examples:

```sh
nix run github:9Prestidigitator/maxpkgs#minimeters-demo
nix run github:9Prestidigitator/maxpkgs#bitwig6
nix build github:9Prestidigitator/maxpkgs#auburn-sounds-free
```

## Plugin Paths

Most DAWs need their plugin scan paths pointed at the active profile or system profile. On NixOS with `environment.systemPackages`, use:

| Format | System path                       |
| ------ | --------------------------------- |
| CLAP   | `/run/current-system/sw/lib/clap` |
| LV2    | `/run/current-system/sw/lib/lv2`  |
| VST2   | `/run/current-system/sw/lib/vst`  |
| VST3   | `/run/current-system/sw/lib/vst3` |

For Home Manager or user-profile installs, use the matching paths under `~/.nix-profile/lib` or `$HOME/.local/state/nix/profile/lib`.

## Overwitch Module

The Overwitch NixOS module installs the package, adds the udev rules, and starts the user service after PipeWire:

```nix
{
  imports = [inputs.maxpkgs.nixosModules.overwitch];

  services.overwitch.enable = true;
}
```

## Paid Packages

Paid binaries are not redistributed. Purchase them yourself, then provide the matching archive hash when overriding the package. Hashes are safe in Nix code; credentials and license keys are not. A built paid package is still stored in the Nix store.

> [!NOTE]
> The paid package paths are untested here.

### Configure a package

```nix
{pkgs, ...}: let
  minimetersPaid = pkgs.minimeters.override {
    paidHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  auburnPaid = pkgs.auburn-sounds.override {
    fullHashes = {
      selene = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
      "inner-pitch" = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
    };
  };

  pianoteqPaid = pkgs.pianoteq.override {
    hashes = {
      standard_9 = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=";
      stage_9 = "sha256-EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=";
    };
  };
in {
  environment.systemPackages = [
    minimetersPaid.full
    auburnPaid.selene.full
    pianoteqPaid.standard
  ];
}
```

### Local archives: MiniMeters and Auburn Sounds

Download the archive from the vendor, calculate its SRI hash, and add it to the store before building:

```sh
nix hash file --type sha256 --sri ~/Downloads/ARCHIVE.zip
nix-store --add-fixed sha256 ~/Downloads/ARCHIVE.zip
```

Use that hash as `minimeters.paidHash` or the relevant `auburn-sounds.fullHashes` entry. MiniMeters uses `minimeters-linux.zip` on x86_64 and `minimeters-linux-arm64.zip` on ARM. Auburn Sounds uses the product's `*-FULL-<version>.zip` archive. The free editions need no override; `inner-pitch-full` is a convenient alias for the paid Inner Pitch edition.

### Pianoteq Standard and Stage

`pianoteq` and `pianoteq-trial` are the public Standard trial. The paid packages download from your Modartt account using `NIX_MODARTT_USERNAME` and `NIX_MODARTT_PASSWORD` in the local Nix daemon environment, then need the resulting hash in the `hashes` override above.

Keep these credentials in a secret-manager-generated `EnvironmentFile` for `nix-daemon`, outside the Nix store. Use only trusted local builders and do not use remote builders or public binary caches for these builds. After updating the environment file, restart `nix-daemon`.

## Inspirations

- [audio.nix](https://github.com/polygon/audio.nix)
- [nix-gaming](https://github.com/fufexan/nix-gaming)
- The upstream developers and vendors linked in the package table above.
