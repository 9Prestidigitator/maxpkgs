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
  version = "2.1.5.0";

  src = fetchurl {
    url = "https://cdn1.resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-${finalAttrs.version}-VST3-64bit-Linux-FULL.zip";
    hash = "sha256-kL+1M4s+d28rHuhW4yuCxDa2he3Q2uYVty3aENFCzUQ=";
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
    maintainers = with lib.maintainers; [polygon];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
