{
  alsa-lib,
  cmake,
  cpm-cmake,
  curl,
  fetchFromGitHub,
  fetchNpmDeps,
  fontconfig,
  freetype,
  gtk3,
  lib,
  libGL,
  libX11,
  libXcomposite,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr,
  libXrender,
  libjack2,
  libsysprof-capture,
  libxkbcommon,
  nodejs,
  npmHooks,
  patchelf,
  pcre2,
  pkg-config,
  stdenv,
  webkitgtk_4_1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tone-3000-plugin";
  version = "0.0.3-unstable-2026-09-02";

  src = fetchFromGitHub {
    owner = "tone-3000";
    repo = "tone3000-plugin";
    rev = "83ca7aadb3776be188dc8a3e758c78e133451591";
    hash = "sha256-NaADGMB5oixqY3chTAcDpmM1gMC2mOYDw3hU1BcxiD4=";
    fetchSubmodules = true;
  };

  juce = fetchFromGitHub {
    owner = "juce-framework";
    repo = "JUCE";
    tag = "9.0.1";
    hash = "sha256-9YbhXKBVER7Ww9pwwd1gwm9R8/975pCNibsCqGviYTk=";
  };

  googletest = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    tag = "v1.15.2";
    hash = "sha256-1OJ2SeSscRBNr7zZ/a8bJGIqAnhkg45re0j3DtPfcXM=";
  };

  clapJuceExtensions = fetchFromGitHub {
    owner = "free-audio";
    repo = "clap-juce-extensions";
    rev = "c1a5ad025f95d01e03267857fa8276ebeed16500";
    hash = "sha256-P8rLNI9fXGU8yxXXdOkRD/+T3AMd3zdRM8mHp62dEmA=";
    fetchSubmodules = true;
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/ui";
    hash = "sha256-qqmF4etA+GqlgHhycztvFvu2MUZcjtPMwRvnDIrHpTw=";
  };

  npmRoot = "ui";

  nativeBuildInputs =
    [
      cmake
      nodejs
      npmHooks.npmConfigHook
      pkg-config
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux patchelf;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    curl
    fontconfig
    freetype
    gtk3
    libGL
    libX11
    libXcomposite
    libXcursor
    libXext
    libXinerama
    libXrandr
    libXrender
    libjack2
    libsysprof-capture
    libxkbcommon
    pcre2
    webkitgtk_4_1
  ];

  postPatch = ''
    mkdir -p libs/cpm
    cp ${cpm-cmake}/share/cpm/CPM.cmake libs/cpm/CPM_0.40.2.cmake

    cp -r ${finalAttrs.juce} libs/juce
    cp -r ${finalAttrs.googletest} libs/googletest
    cp -r ${finalAttrs.clapJuceExtensions} libs/clap-juce-extensions
    chmod -R u+w libs
  '';

  preConfigure = ''
    pushd ui
    npm run build
    popd

    cmakeFlagsArray+=(
      "-DCPM_JUCE_SOURCE=$PWD/libs/juce"
      "-DCPM_GOOGLETEST_SOURCE=$PWD/libs/googletest"
      "-DCPM_clap-juce-extensions_SOURCE=$PWD/libs/clap-juce-extensions"
    )
  '';

  cmakeFlags =
    [
      "-DBUILD_AAX=OFF"
      "-DBUILD_CLAP=ON"
      "-DBUILD_LV2=ON"
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux "-DCMAKE_TOOLCHAIN_FILE=../cmake/linux-toolchain.cmake";

  buildFlags = [
    "TONE3000_CLAP"
    "TONE3000_LV2"
    "TONE3000_VST3"
  ];

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      artefacts=plugin/TONE3000_artefacts/Release
      mkdir -p \
        "$out/Library/Audio/Plug-Ins/CLAP" \
        "$out/Library/Audio/Plug-Ins/LV2" \
        "$out/Library/Audio/Plug-Ins/VST3"
      cp -R "$artefacts/CLAP/TONE3000.clap" "$out/Library/Audio/Plug-Ins/CLAP/"
      cp -R "$artefacts/LV2/TONE3000.lv2" "$out/Library/Audio/Plug-Ins/LV2/"
      cp -R "$artefacts/VST3/TONE3000.vst3" "$out/Library/Audio/Plug-Ins/VST3/"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      artefacts=plugin/TONE3000_artefacts/Release
      mkdir -p "$out/lib/clap" "$out/lib/lv2" "$out/lib/vst3"
      install -Dm755 "$artefacts/CLAP/TONE3000.clap" "$out/lib/clap/TONE3000.clap"
      cp -r "$artefacts/LV2/TONE3000.lv2" "$out/lib/lv2/"
      cp -r "$artefacts/VST3/TONE3000.vst3" "$out/lib/vst3/"

      runHook postInstall
    '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    runtimeLibraryPath=${lib.makeLibraryPath [curl gtk3 webkitgtk_4_1]}
    patchelf --add-rpath "$runtimeLibraryPath" "$out/lib/clap/TONE3000.clap"
    patchelf --add-rpath "$runtimeLibraryPath" "$out/lib/lv2/TONE3000.lv2/libTONE3000.so"
    patchelf --add-rpath "$runtimeLibraryPath" "$out/lib/vst3/TONE3000.vst3/Contents/${stdenv.hostPlatform.linuxArch}-linux/TONE3000.so"
  '';

  meta = {
    description = "NAM and impulse-response loader integrated with TONE3000";
    homepage = "https://github.com/tone-3000/tone3000-plugin";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
