{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cmake,
  expat,
  fontconfig,
  pkg-config,
  freetype,
  glib,
  libGL,
  libGLU,
  libXau,
  libXdmcp,
  libx11,
  libxcb,
  libxkbcommon,
  pango,
  sysprof,
  xcbutil,
  xcbutilcursor,
  xcbutilkeysyms,
  xcbutilwm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "js-inflator";
  version = "2.0.3.2";

  src = fetchFromGitHub {
    owner = "Kiriki-liszt";
    repo = "JS_Inflator";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-Kb06he5EeCCe9jS2o9ZsIlaJ5mBVpys8YpbBNZDHk/s=";
  };

  vst3sdk = fetchFromGitHub {
    owner = "steinbergmedia";
    repo = "vst3sdk";
    tag = "v3.7.12_build_20";
    fetchSubmodules = true;
    hash = "sha256-ZouChCPo+LM9OPkjLY8d+VVnwtsMmTMU6zz8IX/SSDA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    cairo
    expat
    fontconfig
    freetype
    glib
    libGL
    libGLU
    libXau
    libXdmcp
    libx11
    libxcb
    libxkbcommon
    pango
    sysprof
    xcbutil
    xcbutilcursor
    xcbutilkeysyms
    xcbutilwm
  ];

  postPatch = ''
    cp -r ${finalAttrs.vst3sdk} vst3sdk
    chmod -R u+w vst3sdk
    patchShebangs vst3sdk
    substituteInPlace vst3sdk/cmake/modules/SMTG_VstGuiSupport.cmake \
      --replace-fail "set(VSTGUI_STANDALONE ON)" "set(VSTGUI_STANDALONE OFF)"
  '';

  preConfigure = ''
    cmakeFlagsArray+=("-Dvst3sdk_SOURCE_DIR=$PWD/vst3sdk")
    cmakeFlagsArray+=("-DSMTG_PLUGIN_TARGET_USER_PATH=$PWD/build/VST3")
  '';

  cmakeFlags =
    lib.optional stdenv.hostPlatform.isLinux "-DCMAKE_CXX_FLAGS=-fpermissive -Wno-changes-meaning"
    ++ [
      "-DSMTG_CREATE_PLUGIN_LINK=OFF"
      "-DSMTG_ENABLE_VST3_PLUGIN_EXAMPLES=OFF"
      "-DSMTG_ENABLE_VST3_HOSTING_EXAMPLES=OFF"
      "-DSMTG_ENABLE_VSTGUI_SUPPORT=ON"
      "-DSMTG_MDA_VST3_VST2_COMPATIBLE=OFF"
    ];

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      mkdir -p "$out/Library/Audio/Plug-Ins/VST3"
      cp -R VST3/Release/JS_Inflator.vst3 "$out/Library/Audio/Plug-Ins/VST3/"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      mkdir -p $out/lib/vst3
      cp -r VST3/Release/JS_Inflator.vst3 $out/lib/vst3/

      runHook postInstall
    '';

  meta = {
    description = "Open source VST3 inflator audio effect plugin";
    homepage = "https://github.com/Kiriki-liszt/JS_Inflator";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [9 prestidigitator];
    platforms = lib.platforms.linux ++ ["aarch64-darwin"];
  };
})
