{
  alsa-lib,
  boost,
  cmake,
  fetchFromGitHub,
  ffmpeg_6,
  fontconfig,
  freetype,
  lib,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXinerama,
  libXi,
  libXrandr,
  libXtst,
  libxcb,
  libxcb-cursor,
  libxcb-errors,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libjack2,
  libwebp,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "audiogridder";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "apohl79";
    repo = "audiogridder";
    tag = "release_${lib.replaceStrings ["."] ["_"] finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-1S0eUXNHSxrj/VlzJZORsz7DeLuK1CFBl5G5i05zbiU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    boost
    ffmpeg_6
    fontconfig
    freetype
    libGL
    libX11
    libXcursor
    libXext
    libXinerama
    libXi
    libXrandr
    libXtst
    libjack2
    libwebp
    libxcb
    libxcb-cursor
    libxcb-errors
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
  ];

  postPatch = ''
      substituteInPlace CMakeLists.txt \
        --replace-fail "/usr/bin/strip" "${stdenv.cc.bintools.targetPrefix}strip"

      substituteInPlace cmake/FindWebP.cmake \
        --replace-fail '${"\${FFMPEG_ROOT}"}/include' '${"\${WEBP_ROOT}"}/include' \
        --replace-fail '${"\${FFMPEG_ROOT}"}/lib' '${"\${WEBP_ROOT}"}/lib'

      substituteInPlace cmake/FindFFmpeg.cmake \
        --replace-fail '${"\${FFMPEG_ROOT}"}/lib' '${lib.getLib ffmpeg_6}/lib'

      substituteInPlace PluginTray/CMakeLists.txt \
        --replace-fail \
          'juce::juce_graphics' \
          'juce::juce_audio_processors
    juce::juce_graphics'
  '';

  cmakeFlags = [
    "-DAG_ENABLE_DYNAMIC_LINKING=ON"
    "-DAG_ENABLE_CODE_SIGNING=OFF"
    "-DAG_WITH_PLUGIN=ON"
    "-DAG_WITH_SERVER=ON"
    "-DAG_WITH_TESTS=OFF"
    "-DAG_WITH_TRACEREADER=OFF"
    "-DFFMPEG_ROOT=${lib.getDev ffmpeg_6}"
    "-DWEBP_ROOT=${libwebp}"
  ];

  cmakeBuildType = "RelWithDebInfo";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib/vst3" "$out/share/applications" "$out/share/pixmaps"

    for plugin in AudioGridder AudioGridderInst AudioGridderMidi; do
      install -Dm755 "lib/$plugin.so" "$out/lib/vst3/$plugin.vst3/Contents/${stdenv.hostPlatform.linuxArch}-linux/$plugin.so"
    done

    install -Dm755 bin/AudioGridderPluginTray "$out/bin/AudioGridderPluginTray"
    install -Dm755 bin/AudioGridderServer "$out/bin/AudioGridderServer"
    install -Dm644 ../package/audiogridderserver.desktop "$out/share/applications/audiogridderserver.desktop"
    install -Dm644 ../Server/Resources/icon.png "$out/share/pixmaps/audiogridderserver.png"
    substituteInPlace "$out/share/applications/audiogridderserver.desktop" \
      --replace-fail "Exec=/usr/local/bin/AudioGridderServer" "Exec=$out/bin/AudioGridderServer" \
      --replace-fail "Icon=/usr/local/share/audiogridder/icon64.png" "Icon=audiogridderserver"

    runHook postInstall
  '';

  meta = {
    description = "Network bridge for audio plugins";
    homepage = "https://github.com/apohl79/audiogridder";
    license = lib.licenses.gpl3Only;
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "AudioGridderServer";
  };
})
