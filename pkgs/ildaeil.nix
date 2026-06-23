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
  makeWrapper,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ildaeil";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "Ildaeil";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-Jm886EWWv0/BOC2f0S+U7wurpaBunThcUk3YdPa+k/4=";
  };

  nativeBuildInputs = [
    makeWrapper
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
    "PREFIX=$(out)"
  ];

  postPatch = ''
    patchShebangs dpf/utils
  '';

  postInstall = ''
    find "$out" -name 'carla-*' -type f -exec chmod 755 {} +
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Mini plugin host as a plugin";
    homepage = "https://github.com/DISTRHO/Ildaeil";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [magnetophon];
    platforms = lib.platforms.linux;
  };
})
