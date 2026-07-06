{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neural-amp-modeler-lv2";
  version = "v0.2.1";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    tag = finalAttrs.version;
    deepClone = true;
    fetchSubmodules = true;
    postFetch = "rm -rf $out/.git";
    hash = "sha256-tTvp22Pqr9Be96Xw+14GDTs0rUCL65nFl8o/yyeRHsQ=";
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
