{
  alsa-lib,
  cmake,
  fetchFromGitHub,
  fetchurl,
  curl,
  fontconfig,
  freetype,
  lib,
  libGL,
  libjack2,
  libX11,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr,
  python3,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neuralnote";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "DamRsn";
    repo = "NeuralNote";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-5r+MxLof+hKZf+koMJG+qdOBdHsv8AI0l/+WJTTISVM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs =
    [
      curl
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
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
    ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(COPY_PLUGIN_AFTER_BUILD TRUE)' 'set(COPY_PLUGIN_AFTER_BUILD FALSE)'

    # Supply the pinned soundfonts locally; the build must not use the network.
    mkdir -p NeuralNote/Assets/SoundFont
    cp ${finalAttrs.musescoreSoundfont} NeuralNote/Assets/SoundFont/MuseScore_General.sf3
    cp ${finalAttrs.fluidSoundfont} NeuralNote/Assets/SoundFont/FluidR3Mono_GM.sf3
    python3 Tools/make_soundfont.py
  '';

  musescoreSoundfont = fetchurl {
    url = "https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/MuseScore_General.sf3";
    sha256 = "5b85b6c2c61d10b2b91cddd41efcce7b25cd31c8271d511c73afafbef20b6fa3";
  };
  fluidSoundfont = fetchurl {
    url = "https://raw.githubusercontent.com/musescore/MuseScore/45924076871483cb96b859cc374c5fbdbf76ba53/share/sound/FluidR3Mono_GM.sf3";
    sha256 = "cfcd66d89e8386823400eca64934b14fbea7bf48ba1f00d21189af1262794ec2";
  };
  ggmlSrc = fetchFromGitHub {
    owner = "ggml-org";
    repo = "ggml";
    rev = "e91ded11bdcd78c42f9c8d3978ff6686eb4c1226";
    hash = "sha256-QArqnQ5//Ft9Knm1Caqz68t4ikNQnk+O+OZUTfZlVCk=";
  };

  cmakeFlags =
    [
      (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_GGML" "${finalAttrs.ggmlSrc}")
      (lib.cmakeBool "NEURALNOTE_FETCH_SOUNDFONT" false)
      (lib.cmakeBool "NEURALNOTE_SYMBOLS" false)
      (lib.cmakeBool "MUSCRIPTOR_METAL_PRECOMPILED" false)
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
      "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
      "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
    ];

  preConfigure = ''
    export CMAKE_BUILD_PARALLEL_LEVEL="$NIX_BUILD_CORES"
  '';

  cmakeBuildType = "Release";

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      artefacts=NeuralNote_artefacts/Release
      mkdir -p \
        "$out/Applications" \
        "$out/Library/Audio/Plug-Ins/Components" \
        "$out/Library/Audio/Plug-Ins/VST3"
      cp -R "$artefacts/Standalone/NeuralNote.app" "$out/Applications/"
      cp -R "$artefacts/AU/NeuralNote.component" "$out/Library/Audio/Plug-Ins/Components/"
      cp -R "$artefacts/VST3/NeuralNote.vst3" "$out/Library/Audio/Plug-Ins/VST3/"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/lib/vst3"
      cp -R NeuralNote_artefacts/Release/VST3/. "$out/lib/vst3/"
      cp -R NeuralNote_artefacts/Release/Standalone/. "$out/bin/"

      runHook postInstall
    '';

  postInstall = ''
    install -Dm644 ../Installers/license.txt $out/share/licenses/neuralnote/license.txt
  '';

  # JUCE loads these libraries dynamically; keep them in the runtime closure.
  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isLinux (toString [
    "--no-as-needed"
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
    "--as-needed"
  ]);

  meta = {
    description = "Audio plug-in for automatic music transcription";
    homepage = "https://github.com/DamRsn/NeuralNote";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [polygon];
    platforms = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    mainProgram = "NeuralNote";
  };
})
