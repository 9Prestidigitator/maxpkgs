{
  alsa-lib,
  cairo,
  fetchFromGitHub,
  lib,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXrandr,
  liblo,
  libjack2,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ildaeil";
  version = "unstable-2026-06-23";

  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "Ildaeil";
    rev = "af9fc9f73b1a1832da8d6dfa12f7d03c431293d6";
    fetchSubmodules = true;
    hash = "sha256-7oayKRqAHXEkf3PMsma3HfuHYXrNNR+xkrHyYrZ7s5I=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    cairo
    libGL
    libX11
    libXcursor
    libXext
    libXrandr
    libjack2
    liblo
  ];

  makeFlags = [
    "AR=gcc-ar"
    "PREFIX=$(out)"
  ];

  postPatch = ''
    patchShebangs dpf/utils

    # jackbridge.a and jackbridge.min.a share JackBridge2.cpp.o. Building
    # them concurrently can leave the latter with a corrupt symbol index.
    substituteInPlace carla/Makefile \
      --replace-fail \
        '$(MODULEDIR)/jackbridge.%.a: .FORCE' \
        '$(MODULEDIR)/jackbridge.min.a: $(MODULEDIR)/jackbridge.a
    $(MODULEDIR)/jackbridge.%.a: .FORCE'

    substituteInPlace plugins/Common/IldaeilPlugin.cpp \
      --replace-fail \
        'path = getHomePath() + "/.lv2:/usr/lib/lv2:/usr/local/lib/lv2";' \
        'path = getHomePath() + "/.lv2:/run/current-system/sw/lib/lv2:/usr/lib/lv2:/usr/local/lib/lv2";'
  '';

  postInstall = ''
    find "$out" -name 'carla-*' -type f -exec chmod 755 {} +
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Mini plugin host as a plugin";
    homepage = "https://github.com/DISTRHO/Ildaeil";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
