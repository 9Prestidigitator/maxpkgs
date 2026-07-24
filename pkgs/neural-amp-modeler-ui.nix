{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cairo,
  libX11,
  lv2,
  neural-amp-modeler-lv2,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neural-amp-modeler-ui";
  version = "unstable-2026-06-07";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "neural-amp-modeler-ui";
    rev = "ee23316ceb47256273414dda1a5b640f35d41d4e";
    fetchSubmodules = true;
    hash = "sha256-DvonS7YqHAnDDsxBoGMbfG/lnENve2aZ9NdWaKXxrAE=";
  };

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    cairo
    libX11
    lv2
  ];

  installPhase = ''
    runHook preInstall

    bundle="$out/lib/lv2/neural_amp_modeler.lv2"
    mkdir -p "$out/lib/lv2"
    cp -r ${neural-amp-modeler-lv2}/lib/lv2/neural_amp_modeler.lv2 "$bundle"
    chmod -R u+w "$bundle"
    cp bin/Neural_Amp_Modeler_ui.lv2/Neural_Amp_Modeler_ui.* "$bundle/"
    substituteInPlace "$bundle/manifest.ttl" \
      --replace-fail \
        'rdfs:seeAlso <neural_amp_modeler.ttl>,<modgui.ttl>.' \
        'rdfs:seeAlso <neural_amp_modeler.ttl>,<modgui.ttl>,<Neural_Amp_Modeler_ui.ttl>.'

    runHook postInstall
  '';

  meta = {
    description = "X11 UI for the Neural Amp Modeler LV2 plugin";
    homepage = "https://github.com/brummer10/neural-amp-modeler-ui";
    license = lib.licenses.bsd0;
    platforms = lib.platforms.linux;
  };
})
