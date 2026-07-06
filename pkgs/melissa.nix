{
  alsa-lib,
  cmake,
  copyDesktopItems,
  curl,
  fontconfig,
  freetype,
  gtk3,
  lib,
  fetchFromGitHub,
  libGL,
  libjack2,
  libX11,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr,
  libxkbcommon,
  makeDesktopItem,
  onnxruntime,
  pkg-config,
  spleeterpp,
  stdenv,
  webkitgtk_4_1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "melissa";
  version = "4.0.2-unstable-2026-06-16";

  src = fetchFromGitHub {
    owner = "mosynthkey";
    repo = "Melissa";
    rev = "67133449ad02e23f873308ca130874213479386c";
    hash = "sha256-TC6IHbJ2YXCwAJswFzCSdHLuCFdxAxtH8aplzYNghA0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    curl
    fontconfig
    freetype
    gtk3
    gtk3.dev
    libGL
    libjack2
    libX11
    libXcursor
    libXext
    libXinerama
    libXrandr
    libxkbcommon
    onnxruntime
    onnxruntime.dev
    spleeterpp
    webkitgtk_4_1
    webkitgtk_4_1.dev
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "ThirdParty/spleeterpp/include" "${spleeterpp}/include" \
      --replace-fail "ThirdParty/libtensorflow-cpu-darwin-universal-binary-2.8.0/include" "${spleeterpp}/include" \
      --replace-fail "ThirdParty/libonnxruntime/include" "${onnxruntime.dev}/include" \
      --replace-fail "-L\''${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty/spleeterpp/lib" "-L${spleeterpp}/lib" \
      --replace-fail "-L\''${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty/libtensorflow-cpu-darwin-universal-binary-2.8.0/lib" "-L${spleeterpp}/lib" \
      --replace-fail "    tensorflow" "    tensorflow
    tensorflow_framework
    onnxruntime"

    substituteInPlace Source/MelissaStemProvider.cpp \
      --replace-fail 'auto model_path = settingsDir.getChildFile("models").getFullPathName().toStdString();' \
        'auto model_path = String("${spleeterpp}/models/default").toStdString();'

    substituteInPlace Source/UI/MelissaStemSeparationSelectComponent.cpp \
      --replace-fail 'addAndMakeVisible(optionButtons_[kOption_Demucs].get());' \
        'addChildComponent(optionButtons_[kOption_Demucs].get());'
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "melissa";
      exec = "Melissa";
      desktopName = "Melissa";
      icon = "melissa";
      comment = finalAttrs.meta.description;
      categories = [
        "AudioVideo"
        "Audio"
      ];
      startupNotify = false;
    })
  ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags gtk+-3.0 webkit2gtk-4.1)"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 Melissa_artefacts/Release/Melissa $out/bin/Melissa
    install -Dm644 ../Resource/icon.png $out/share/icons/hicolor/512x512/apps/melissa.png
    install -Dm644 ../Resource/icon.png $out/share/icons/hicolor/1024x1024/apps/melissa.png

    runHook postInstall
  '';

  env.NIX_LDFLAGS = toString [
    "-lcurl"
    "-L${spleeterpp}/lib"
    "-lspleeter"
    "-lspleeter_common"
    "-ltensorflow"
    "-ltensorflow_framework"
    "-L${onnxruntime}/lib"
    "-lonnxruntime"
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ];

  meta = {
    description = "Music player for musical instrument practice";
    homepage = "https://github.com/mosynthkey/Melissa";
    longDescription = ''
      Built from upstream master because Linux support has not been released in a
      tagged version yet.
    '';
    license = lib.licenses.lgpl21Only;
    platforms = ["x86_64-linux"];
    mainProgram = "Melissa";
  };
})
