{
  lib,
  stdenv,
  fetchurl,
  fetchDebianPatch,
  alsa-lib,
  expat,
  glib,
  libjack2,
  libxext,
  libx11,
  libpng,
  libpthread-stubs,
  libsmf,
  libsndfile,
  lv2,
  pkg-config,
  zita-resampler,
}:
stdenv.mkDerivation rec {
  version = "0.9.20";
  pname = "drumgizmo";

  src = fetchurl {
    url = "https://www.drumgizmo.org/releases/${pname}-${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-AF8gQLiB29j963uI84TyNHIC0qwEWOCqmZIUWGq8V2o=";
  };

  patches =
    [
      (fetchDebianPatch {
        pname = "drumgizmo";
        version = "0.9.20";
        debianRevision = "3";
        patch = "0005-fix_ftbfs_with_gcc13.patch";
        hash = "sha256-y5NDZ+3t6GkBeF/5UY8dwtH8k0cuM+5SGBGPSV7AX7M=";
      })
      ./drumgizmo/fix-non-ascii.patch
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      ./drumgizmo/fix-cocoa-editor.patch
    ];

  configureFlags =
    ["--enable-lv2"]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "--disable-input-alsamidi"
      "--disable-output-alsa"
    ];

  nativeBuildInputs = [pkg-config];

  buildInputs =
    [
      expat
      glib
      libjack2
      libpng
      libsmf
      libsndfile
      lv2
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      libxext
      libx11
      libpthread-stubs
      zita-resampler
    ];

  meta = {
    description = "LV2 sample based drum plugin";
    homepage = "https://www.drumgizmo.org";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [lib.maintainers.nico202];
  };
}
