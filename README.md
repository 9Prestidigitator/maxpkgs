# maxpkgs

Personal Nix packages, overlays, and small NixOS modules for audio tools I use that are missing from nixpkgs, need newer versions, or need packaging choices that fit my systems.

This repo is Linux-audio heavy. Several packages are proprietary or otherwise unfree, so read the upstream license before using or redistributing anything.

## What is included

| Attribute                                                                                                                                                                          | Upstream                                                                           | Installs                      | Notes                                                                                           |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------- |
| `bitwig6`                                                                                                                                                                          | [Bitwig Studio](https://www.bitwig.com/)                                           | DAW                           | Linux `.deb` repackaged for Nix.                                                                |
| `overwitch`                                                                                                                                                                        | [Overwitch](https://dagargo.github.io/overwitch/)                                  | JACK client and helper tools  | Includes `nixosModules.overwitch`.                                                              |
| `pianoteq`, `pianoteq-trial`                                                                                                                                                       | [Modartt Pianoteq](https://www.modartt.com/pianoteq)                               | Standalone, LV2, VST3         | Defaults to the Standard trial.                                                                 |
| `pianoteq-standard`, `pianoteq-stage`                                                                                                                                              | [Modartt Pianoteq](https://www.modartt.com/pianoteq)                               | Standalone, LV2, VST3         | Paid downloads. See [Paid Packages](#paid-packages).                                            |
| `minimeters`, `minimeters-demo`                                                                                                                                                    | [MiniMeters](https://minimeters.app/)                                              | Standalone, CLAP, VST3        | Defaults to the free demo.                                                                      |
| `minimeters-full`                                                                                                                                                                  | [MiniMeters](https://minimeters.app/)                                              | Standalone, CLAP, VST3        | Paid itch.io archive. See [Paid Packages](#paid-packages).                                      |
| `auburn-sounds`, `auburn-sounds-free`                                                                                                                                              | [Auburn Sounds](https://www.auburnsounds.com/)                                     | CLAP, LV2, VST2, VST3         | Free editions of the current suite.                                                             |
| `auburn-sounds-full`                                                                                                                                                               | [Auburn Sounds](https://www.auburnsounds.com/)                                     | CLAP, LV2, VST2, VST3         | Paid full editions. See [Paid Packages](#paid-packages).                                        |
| `auburn-sounds-selene`, `auburn-sounds-graillon`, `auburn-sounds-inner-pitch`, `auburn-sounds-lens`, `auburn-sounds-panagement`, `auburn-sounds-renegate`, `auburn-sounds-couture` | [Auburn Sounds](https://www.auburnsounds.com/)                                     | CLAP, LV2, VST2, VST3         | Individual free editions. Each also exposes `.full` and `.paid` passthru attrs.                 |
| `inner-pitch`, `inner-pitch-free`, `inner-pitch-full`                                                                                                                              | [Auburn Sounds Inner Pitch](https://www.auburnsounds.com/products/InnerPitch.html) | CLAP, LV2, VST2, VST3         | Convenience aliases for the Auburn Sounds package.                                              |
| `gvst`                                                                                                                                                                             | [GVST](https://gvst.uk/)                                                           | VST2                          | GVST Linux plugin suite.                                                                        |
| `amplocker`                                                                                                                                                                        | [AudioAssault](https://audioassault.mx/)                                           | Standalone, LV2, VST3         | Free Amp Locker package.                                                                        |
| `drumlocker`                                                                                                                                                                       | [AudioAssault Drum Locker](https://audioassault.mx/getdrumlocker)                  | LV2, VST3, sample data helper | Run `drum-locker-install-data` if the plugin needs writable sample data in your home directory. |
| `mixlocker`                                                                                                                                                                        | [AudioAssault Mix Locker](https://audioassault.mx/getmixlocker)                    | LV2, VST3, preset/data helper | Run `mix-locker-install-data` if the plugin needs writable data in your home directory.         |
| `mt-power-drumkit-2`                                                                                                                                                               | [MT Power Drum Kit 2](https://www.powerdrumkit.com/)                               | VST3                          | Free drum sampler plugin.                                                                       |
| `neuralnote`                                                                                                                                                                       | [NeuralNote](https://github.com/DamRsn/NeuralNote)                                 | Standalone, VST3              | Automatic transcription tool.                                                                   |
| `neural-amp-modeler-lv2`                                                                                                                                                           | [NAM LV2](https://github.com/mikeoliphant/neural-amp-modeler-lv2)                  | LV2                           | Neural Amp Modeler LV2 implementation.                                                          |
| `js-inflator`                                                                                                                                                                      | [JS_Inflator](https://github.com/Kiriki-liszt/JS_Inflator)                         | VST3                          | Open source inflator effect.                                                                    |
| `rubberband`                                                                                                                                                                       | [Rubber Band Library](https://breakfastquay.com/rubberband/)                       | Library and audio plugins     | Exposed as `rubberband-lv2` from the overlay to avoid clashing with nixpkgs.                    |
| `libonnxruntime-neuralnote`                                                                                                                                                        | [ONNX Runtime](https://onnxruntime.ai/)                                            | Support library               | Usually not installed directly.                                                                 |

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

Most DAWs need their plugin scan paths pointed at the active profile or system
profile. On NixOS with `environment.systemPackages`, use:

| Format | System path                       |
| ------ | --------------------------------- |
| CLAP   | `/run/current-system/sw/lib/clap` |
| LV2    | `/run/current-system/sw/lib/lv2`  |
| VST2   | `/run/current-system/sw/lib/vst`  |
| VST3   | `/run/current-system/sw/lib/vst3` |

For Home Manager or user-profile installs, use the matching paths under
`~/.nix-profile/lib` or `$HOME/.local/state/nix/profile/lib`.

## Overwitch Module

The Overwitch NixOS module installs the package, adds the udev rules, and starts the user service after PipeWire:

```nix
{
  imports = [inputs.maxpkgs.nixosModules.overwitch];

  services.overwitch.enable = true;
}
```

## Paid Packages

Paid packages are not redistributed from this repository. The Nix expressions describe how to install files you already have access to, but you must provide your own licensed downloads or credentials.

Hashes are not secrets. They can live in your flake, host config, or overlay. Credentials and license keys are secrets and should not be interpolated into Nix expressions, derivation arguments, `environment.variables`, or files generated in the Nix store.

Normal derivations cannot safely read `/run/secrets` or `/run/current-system/secrets`: those paths exist at activation/runtime, while system packages must be built before activation. If a paid plugin is installed as a Nix package, the paid plugin binary itself will be present in the Nix store.

For sops-nix or agenix, use secret files for runtime credentials or daemon environment files, and keep only fixed-output hashes in Nix code.

> [!ATTENTION]
> These paid packages have not officially been tested yet, as I have not purchased them myself yet.

### Hash Overrides

Paid package hashes are configurable as package arguments, so you do not need to edit package files.

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

### MiniMeters Full

`minimeters` and `minimeters-demo` build the public demo. `minimeters-full` uses the paid Linux archive from itch.io via `requireFile`.

1. Purchase MiniMeters from [directmusic.itch.io/minimeters](https://directmusic.itch.io/minimeters).
2. Download the Linux archive:
   - `minimeters-linux.zip` on `x86_64-linux`
   - `minimeters-linux-arm64.zip` on `aarch64-linux`
3. Compute the hash:

```sh
nix hash file --type sha256 --sri ~/Downloads/minimeters-linux.zip
```

4. Override `paidHash` with that hash.
5. Add the archive to the Nix store and build:

```sh
nix-store --add-fixed sha256 ~/Downloads/minimeters-linux.zip
nix build --impure --expr '
let
  flake = builtins.getFlake "git+file:///path/to/maxpkgs";
in
  (flake.packages.x86_64-linux.minimeters.override {
    paidHash = "sha256-...";
  }).full
'
```

### Auburn Sounds Full Editions

The free Auburn Sounds attrs build directly. Paid full editions use local itch.io archives via `requireFile`.

For one plugin, override the relevant `fullHashes` entry:

```sh
nix hash file --type sha256 --sri ~/Downloads/Selene-FULL-1.1.zip
nix-store --add-fixed sha256 ~/Downloads/Selene-FULL-1.1.zip
nix build --impure --expr '
let
  flake = builtins.getFlake "git+file:///path/to/maxpkgs";
in
  (flake.packages.x86_64-linux.auburn-sounds.override {
    fullHashes.selene = "sha256-...";
  }).selene.full
'
```

For the whole paid suite, override every required `fullHashes` entry, add every `*-FULL-*.zip` file to the store, then build the overridden package set's `full` attr.

```nix
pkgs.auburn-sounds.override {
  fullHashes = {
    selene = "sha256-...";
    graillon = "sha256-...";
    "inner-pitch" = "sha256-...";
    lens = "sha256-...";
    renegate = "sha256-...";
    panagement = "sha256-...";
    couture = "sha256-...";
  };
}
```

`inner-pitch-full` is available as a top-level convenience attr for the paid Inner Pitch package.

### Pianoteq Standard and Stage

`pianoteq` and `pianoteq-trial` use the public Standard trial. Paid Pianoteq builds log into Modartt with `NIX_MODARTT_USERNAME` and `NIX_MODARTT_PASSWORD`, then fetch the account-specific archive as a fixed-output derivation.

For sops-nix or agenix, store a dotenv-style secret file outside the store:

```sh
NIX_MODARTT_USERNAME=you@example.com
NIX_MODARTT_PASSWORD=your-password
```

Then point the Nix daemon at that runtime file. With sops-nix this is typically:

```nix
{config, ...}: {
  sops.secrets.modartt-env = {
    sopsFile = ./secrets.yaml;
    key = "modartt/env";
    mode = "0400";
  };

  systemd.services.nix-daemon.serviceConfig.EnvironmentFile =
    config.sops.secrets.modartt-env.path;
}
```

With agenix:

```nix
{config, ...}: {
  age.secrets.modartt-env.file = ./secrets/modartt-env.age;

  systemd.services.nix-daemon.serviceConfig.EnvironmentFile =
    config.age.secrets.modartt-env.path;
}
```

This keeps the secret file out of the store, but it still makes those environment variables available to the local Nix daemon for derivations that explicitly allow them through `impureEnvVars`. Use this only on trusted local builders. Do not use remote builders or public binary caches for these builds. Restart `nix-daemon` after changing the environment file wiring or secret contents.

For ad-hoc local builds, a direct systemd override works too:

```ini
[Service]
Environment=NIX_MODARTT_USERNAME=you@example.com
Environment=NIX_MODARTT_PASSWORD=your-password
```

Then build once:

```sh
nix build .#pianoteq-standard
```

The first build with `lib.fakeHash` will fetch the archive and fail with the actual hash. Put that hash in your package override, then rebuild:

```nix
pkgs.pianoteq.override {
  hashes = {
    standard_9 = "sha256-...";
    stage_9 = "sha256-...";
  };
}
```

## Inspirations

- [audio.nix](https://github.com/polygon/audio.nix)
- [nix-gaming](https://github.com/fufexan/nix-gaming)
- The upstream developers and vendors linked in the package table above.
