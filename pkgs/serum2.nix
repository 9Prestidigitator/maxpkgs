{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  cairo,
  curl,
  expat,
  fontconfig,
  freetype,
  glib,
  harfbuzz,
  libICE,
  libSM,
  libX11,
  libXext,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-util,
  libxkbcommon,
  openssl,
  pango,
}:
stdenv.mkDerivation {
  pname = "serum2";
  version = "2.1.5-beta";

  src = fetchurl {
    url = "https://www.dropbox.com/scl/fi/vvpvhf5jkk1oxoek5bpss/Serum2_Linux_Beta_26-08-05_b287808.tar.gz?rlkey=se7uqxx4vjjujpnyt099q5pra&st=axyvbui6&dl=1";
    hash = "sha256-mZg4EbzFs1UCwlmpgOb3DDMMUZCvoc2yggq8HT8p6QQ=";
  };

  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = [autoPatchelfHook];

  buildInputs = [
    cairo
    curl
    expat
    fontconfig
    freetype
    glib
    harfbuzz
    libICE
    libSM
    libX11
    libXext
    libxcb
    libxcb-cursor
    libxcb-keysyms
    libxcb-util
    libxkbcommon
    openssl
    pango
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/vst3"
    cp -r . "$out/lib/vst3/Serum2.vst3"

    runHook postInstall
  '';

  meta = {
    description = "Xfer Records Serum 2 wavetable synthesizer";
    homepage = "https://xferrecords.com/products/serum";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
