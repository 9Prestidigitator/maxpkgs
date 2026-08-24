{
  alsa-lib,
  cmake,
  fetchFromGitHub,
  fftwFloat,
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
  onnxruntime,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neuralnote";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "DamRsn";
    repo = "NeuralNote";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-vZdRXXDQvJ8pCtYpp2ZfMfOpPWCx+9trOwO1m4F22Ww=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs =
    [
      fftwFloat
      onnxruntime
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
    substituteInPlace ThirdParty/RTNeural/CMakeLists.txt \
      --replace-fail 'include(cmake/CPM.cmake)' '# CPM is only needed for tests'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'add_library(onnxruntime STATIC IMPORTED)' 'add_library(onnxruntime SHARED IMPORTED)' \
      --replace-fail 'set(COPY_PLUGIN_AFTER_BUILD TRUE)' 'set(COPY_PLUGIN_AFTER_BUILD FALSE)'

    mkdir -p ThirdParty/onnxruntime/lib
    ln -s ${lib.getLib onnxruntime}/lib/libonnxruntime.${
      if stdenv.hostPlatform.isDarwin
      then "dylib"
      else "so"
    } \
      ThirdParty/onnxruntime/lib/libonnxruntime.a
    ln -s ${lib.getDev onnxruntime}/include \
      ThirdParty/onnxruntime/include

    mv Lib/ModelData/features_model.onnx \
      Lib/ModelData/features_model.ort
  '';

  cmakeFlags = lib.optionals stdenv.hostPlatform.isLinux [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

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

  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isLinux (toString [
    "-rpath"
    "${lib.getLib onnxruntime}/lib"
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ]);

  env.LD_LIBRARY_PATH = lib.optionalString stdenv.hostPlatform.isLinux (lib.makeLibraryPath [onnxruntime]);
  env.DYLD_LIBRARY_PATH = lib.optionalString stdenv.hostPlatform.isDarwin (lib.makeLibraryPath [onnxruntime]);

  meta = {
    description = "Audio plug-in for automatic music transcription";
    homepage = "https://github.com/DamRsn/NeuralNote";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [polygon];
    platforms = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    mainProgram = "NeuralNote";
  };
})
