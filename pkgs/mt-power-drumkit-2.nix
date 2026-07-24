{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
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

  src = fetchurl {
    url = "https://cdn1.resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-${finalAttrs.version}-VST3-64bit-Linux-FULL.zip";
    hash = "sha256-lb8RuIdLgDC2y9KSF6hlWXWKlt4jI8tndWk/WVanpGo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
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

  unpackPhase = ''
    unzip -q "$src"
  '';

  installPhase = ''
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
    maintainers = with lib.maintainers; [9prestidigitator];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
