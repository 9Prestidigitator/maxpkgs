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
  zstd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "serum2";
  version = "2.1.5-beta-2026-09-01";

  src =
    {
      x86_64-linux = fetchurl {
        url = "https://www.dropbox.com/scl/fi/shku73xneqtbr1o7j4g58/Serum2_Linux_Beta_26-09-01_aa25b0e_x86_64.tar.xz?rlkey=rup057pnxv5rra65fx9e2voci&st=zuj9xt0e&dl=1";
        hash = "sha256-oz1La+WovvJDHdwEDQbaDD/Lgy/PTmee8VUC4IYBC3o=";
      };
      aarch64-linux = fetchurl {
        url = "https://www.dropbox.com/scl/fi/0bcsve2nucaa1c1hs3us1/Serum2_Linux_Beta_aarch64_26-08-13_3d11ff7.tar.gz?rlkey=zjlxnxvgfbh6g841xlexz9js8&st=4pphshxv&dl=1";
        hash = "sha256-a/RJ09OyRtYMOGqPUEO1vnpJ/2XdePwsxkocV3FVe0g=";
      };
    }
    .${
      stdenv.hostPlatform.system
    };

  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
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
    zstd
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
    platforms = ["x86_64-linux" "aarch64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
