{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neural-amp-modeler-lv2";
  version = "v0.2.0";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    tag = finalAttrs.version;
    deepClone = true;
    fetchSubmodules = true;
    postFetch = "rm -rf $out/.git";
    hash = "sha256-ZKpZBjZNVx8E8O1MfZ0QJDzxI2l9EDkn/59i8+l5sUg=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    maintainers = [lib.maintainers.viraptor];
    description = "Neural Amp Modeler LV2 plugin implementation";
    homepage = finalAttrs.src.meta.homepage;
    license = [lib.licenses.gpl3];
  };
})
