{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  unzip,
  alsa-lib,
  fontconfig,
  freetype,
}: let
  version = "1.1.0";
  vst3 = fetchurl {
    url = "https://github.com/DamRsn/NeuralNote/releases/download/v${version}/NeuralNote_VST3_Linux.zip";
    sha256 = "sha256-DCwfoqQH1poBUbtfFhh/BiaGfBwvl6RWVn6yT6pglRw=";
  };
  standalone = fetchurl {
    url = "https://github.com/DamRsn/NeuralNote/releases/download/v${version}/NeuralNote_Standalone_Linux.zip";
    sha256 = "sha256-10Fm7RJv5YMnVXjF5zMcSCP/uMP+S8byx8pWrJPvOEE=";
  };
in
  stdenv.mkDerivation {
    pname = "NeuralNote";
    inherit version;

    srcs = [
      vst3
      standalone
    ];
    dontUnpack = true;

    nativeBuildInputs = [
      autoPatchelfHook
      unzip
    ];

    buildInputs = [
      alsa-lib
      fontconfig
      freetype
      stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib/vst3

      unzip -q ${vst3} -d $out/lib/vst3
      unzip -q ${standalone} -d $out/bin
      chmod +x $out/bin/NeuralNote

      runHook postInstall
    '';

    meta = with lib; {
      description = "Audio plugin for automatic music transcription";
      homepage = "https://github.com/DamRsn/NeuralNote";
      license = licenses.asl20;
      platforms = ["x86_64-linux"];
      maintainers = with maintainers; [polygon];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  }
