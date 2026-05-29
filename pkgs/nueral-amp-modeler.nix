{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}: let
  neuralAudioSrc = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "NeuralAudio";
    rev = "72c52b12fdb62bd65e3214cd0037f73ce9ff83e9";
    hash = "sha256-xaRwZWo+sDt7VYJXXwxON9BWquP2Txp4iqBDguLEN1M=";
  };

  lv2Src = fetchFromGitHub {
    owner = "lv2";
    repo = "lv2";
    rev = "e9d94328743d630e27a9d322015437fd9080695d";
    hash = "sha256-Hsx9ib14OZy+/JeOZxV2EIycmGrNB8/pWmwXmMMTIi8=";
  };

  neuralAmpModelerCoreSrc = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "NeuralAmpModelerCore";
    rev = "7e3423448e75219c09cce555b5bebccf10950aa2";
    hash = "sha256-Q2lwlP63jZrqKkvmwLneVfyrOSEDC2fcAdz1Rs8seTY=";
  };

  rtNeuralSrc = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "RTNeural";
    rev = "5909c44909cd6100367f62cd04b348de85d57dbf";
    hash = "sha256-+UYTBB6gM8uiZiWmVq0K7zjsE1nya9LnVZLoQg7XRww=";
  };

  mathApproxSrc = fetchFromGitHub {
    owner = "Chowdhury-DSP";
    repo = "math_approx";
    rev = "f6d55e70f0c5e888d3a0c4e252b02b530210c78a";
    hash = "sha256-2dosJYerVrin+goVVHGZWGmEzr/+PMkqCTd6X4RvFU4=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "neural-amp-modeler-lv2";
    version = "0.1.9-unstable-2026-05-27";

    src = fetchFromGitHub {
      owner = "mikeoliphant";
      repo = "neural-amp-modeler-lv2";
      rev = "02ad31944067079cc66d81dae49605bd2f25ce99";
      hash = "sha256-A6NS+kc58Lh1CYX9Szs4/al8EFlq+8nEsgrtPzT6oKs=";
    };

    nativeBuildInputs = [
      cmake
    ];

    postPatch = ''
      rm -rf deps/NeuralAudio deps/lv2
      cp -r --no-preserve=mode,ownership ${neuralAudioSrc} deps/NeuralAudio
      cp -r --no-preserve=mode,ownership ${lv2Src} deps/lv2

      rm -rf deps/NeuralAudio/deps/NeuralAmpModelerCore \
        deps/NeuralAudio/deps/RTNeural \
        deps/NeuralAudio/deps/math_approx
      cp -r --no-preserve=mode,ownership ${neuralAmpModelerCoreSrc} deps/NeuralAudio/deps/NeuralAmpModelerCore
      cp -r --no-preserve=mode,ownership ${rtNeuralSrc} deps/NeuralAudio/deps/RTNeural
      cp -r --no-preserve=mode,ownership ${mathApproxSrc} deps/NeuralAudio/deps/math_approx
    '';

    meta = {
      description = "Neural Amp Modeler LV2 plugin implementation";
      homepage = "https://github.com/mikeoliphant/neural-amp-modeler-lv2";
      license = lib.licenses.gpl3Only;
      maintainers = [];
      platforms = lib.platforms.linux;
    };
  })
