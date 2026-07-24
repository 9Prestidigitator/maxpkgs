{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neural-amp-modeler-lv2";
  version = "v0.2.3";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    tag = finalAttrs.version;
    deepClone = true;
    fetchSubmodules = true;
    postFetch = "rm -rf $out/.git";
    hash = "sha256-40yrWYQDFItGmm6F3jHexjPrn4aLvKv2Dt4l7RMFJXo=";
  };

  nativeBuildInputs = [cmake];

  meta = {
    maintainers = [lib.maintainers.viraptor];
    description = "Neural Amp Modeler LV2 plugin implementation";
    homepage = finalAttrs.src.meta.homepage;
    license = [lib.licenses.gpl3];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
