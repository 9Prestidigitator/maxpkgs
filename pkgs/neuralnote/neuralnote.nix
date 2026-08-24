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

  buildInputs = [
    alsa-lib
    fftwFloat
    fontconfig
    freetype
    libGL
    libjack2
    libX11
    libXcursor
    libXext
    libXinerama
    libXrandr
    onnxruntime
  ];

  postPatch = ''
    substituteInPlace ThirdParty/RTNeural/CMakeLists.txt \
      --replace-fail 'include(cmake/CPM.cmake)' '# CPM is only needed for tests'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'add_library(onnxruntime STATIC IMPORTED)' 'add_library(onnxruntime SHARED IMPORTED)'

    mkdir -p ThirdParty/onnxruntime/lib
    ln -s ${lib.getLib onnxruntime}/lib/libonnxruntime.so \
      ThirdParty/onnxruntime/lib/libonnxruntime.a
    ln -s ${lib.getDev onnxruntime}/include \
      ThirdParty/onnxruntime/include

    mv Lib/ModelData/features_model.onnx \
      Lib/ModelData/features_model.ort
  '';

  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

  cmakeBuildType = "Release";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib/vst3"
    cp -R NeuralNote_artefacts/Release/VST3/. "$out/lib/vst3/"
    cp -R NeuralNote_artefacts/Release/Standalone/. "$out/bin/"

    runHook postInstall
  '';

  env.NIX_LDFLAGS = toString [
    "-rpath"
    "${lib.getLib onnxruntime}/lib"
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [onnxruntime];

  meta = {
    description = "Audio plug-in for automatic music transcription";
    homepage = "https://github.com/DamRsn/NeuralNote";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [polygon];
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "NeuralNote";
  };
})
