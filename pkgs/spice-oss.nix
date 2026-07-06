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

  buildInputs = [
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
      --replace-fail "FORMATS AU VST3 Standalone LV2" "FORMATS VST3 Standalone LV2"
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

  installPhase = ''
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
    platforms = lib.platforms.linux;
    mainProgram = "spice-oss";
  };
})
