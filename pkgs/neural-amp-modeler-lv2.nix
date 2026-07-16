{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neural-amp-modeler-lv2";
  version = "v0.2.2";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    tag = finalAttrs.version;
    deepClone = true;
    fetchSubmodules = true;
    postFetch = "rm -rf $out/.git";
    hash = "sha256-6ciP8h5tiRs71HBF2rf/ZMKLvnrpreNQ2H+vK6Spbko=";
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
