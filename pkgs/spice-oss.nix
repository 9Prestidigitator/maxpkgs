{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  fontconfig,
  freetype,
  libGL,
  libjack2,
  libX11,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr,
  libxkbcommon,
  lv2,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "spice-oss";
  version = "unstable-2026-06-16";

  src = fetchFromGitHub {
    owner = "DatanoiseTV";
    repo = "spice-oss";
    rev = "21f08240330cf4b60c807553ca2029c184867a27";
    hash = "sha256-AhViaX/DeoIiWSL8uQvy3pU7ZvmbhG0rz8GDGMQWgHg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    fontconfig
    freetype
    libGL
    libjack2
    libX11
    libXcursor
    libXext
    libXinerama
    libXrandr
    libxkbcommon
    lv2
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "FORMATS AU VST3 Standalone LV2" "FORMATS ${
      if stdenv.hostPlatform.isDarwin
      then "AU VST3 Standalone"
      else "VST3 Standalone LV2"
    }"
    substituteInPlace CMakeLists.txt \
      --replace-fail "COPY_PLUGIN_AFTER_BUILD TRUE" "COPY_PLUGIN_AFTER_BUILD FALSE"
    substituteInPlace CMakeLists.txt \
      --replace-fail "juce::juce_audio_utils" "juce::juce_audio_processors
        juce::juce_audio_utils"
    substituteInPlace CMakeLists.txt \
      --replace-fail "juce::juce_recommended_lto_flags" ""
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      artefacts=Spice_artefacts/Release
      mkdir -p \
        "$out/Applications" \
        "$out/bin" \
        "$out/Library/Audio/Plug-Ins/Components" \
        "$out/Library/Audio/Plug-Ins/VST3"
      cp -R "$artefacts"/Standalone/*.app "$out/Applications/"
      cp -R "$artefacts"/AU/*.component "$out/Library/Audio/Plug-Ins/Components/"
      cp -R "$artefacts"/VST3/*.vst3 "$out/Library/Audio/Plug-Ins/VST3/"
      ln -s '../Applications/Spice FX.app/Contents/MacOS/Spice FX' "$out/bin/spice-oss"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      mkdir -p $out/bin $out/lib/lv2 $out/lib/vst3
      cp -r Spice_artefacts/Release/LV2/*.lv2 $out/lib/lv2/
      cp -r Spice_artefacts/Release/VST3/*.vst3 $out/lib/vst3/
      install -Dm755 Spice_artefacts/Release/Standalone/* $out/bin/spice-oss

      runHook postInstall
    '';

  meta = {
    description = "Analog modeling saturation plugin with cabinet simulation";
    homepage = "https://github.com/DatanoiseTV/spice-oss";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ ["aarch64-darwin"];
    mainProgram = "spice-oss";
  };
})
