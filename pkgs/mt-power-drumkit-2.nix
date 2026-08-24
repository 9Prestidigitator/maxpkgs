{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cpio,
  p7zip,
  unzip,
  cairo,
  fontconfig,
  glib,
  libX11,
  libxcb,
  libxcb-cursor,
  libxcb-util,
  libxkbcommon,
  pango,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mt-power-drumkit-2";
  version = "2.1.5.1";

  src = fetchurl (
    if stdenv.hostPlatform.isDarwin
    then {
      url = "https://cdn2.resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-${finalAttrs.version}-VST3-Mac-FULL.zip";
      hash = "sha256-f1X7hzgND2+3YWnBL6PmGtEENG5mdmYCeS8yYiANWgk=";
    }
    else {
      url = "https://cdn1.resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-${finalAttrs.version}-VST3-64bit-Linux-FULL.zip";
      hash = "sha256-lb8RuIdLgDC2y9KSF6hlWXWKlt4jI8tndWk/WVanpGo=";
    }
  );

  nativeBuildInputs =
    [unzip]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cpio
      p7zip
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    cairo
    fontconfig
    glib
    libX11
    libxcb
    libxcb-cursor
    libxcb-util
    libxkbcommon
    pango
    stdenv.cc.cc.lib
  ];

  dontBuild = true;
  dontStrip = true;

  unpackPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      unzip -q "$src"
      7z x -y MTPDK-*/INSTALL_MT-PowerDrumKit_VST3.pkg >/dev/null
      mkdir payload
      cd payload
      cpio -idm --quiet < ../Payload~
    ''
    else ''
      unzip -q "$src"
    '';

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      mkdir -p "$out/Library/Audio/Plug-Ins/VST3"
      cp -R Library/Audio/Plug-Ins/VST3/MT-PowerDrumKit.vst3 "$out/Library/Audio/Plug-Ins/VST3/"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      mkdir -p $out/lib/vst3 $out/share/doc/${finalAttrs.pname}
      cp -r MT-PowerDrumKit.vst3 $out/lib/vst3/
      install -Dm644 -t $out/share/doc/${finalAttrs.pname} *.txt

      runHook postInstall
    '';

  meta = {
    description = "Free acoustic drum sampler VST3 plugin";
    homepage = "https://www.powerdrumkit.com/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [9 prestidigitator];
    platforms = ["x86_64-linux" "aarch64-darwin"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
