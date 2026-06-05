{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  libsamplerate,
  libsndfile,
  fftw,
  lv2,
  jdk_headless,
  vamp-plugin-sdk,
  ladspa-header,
  meson,
  ninja,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rubberband";
  version = "4.0.0";

  src = fetchurl {
    url = "https://breakfastquay.com/files/releases/rubberband-${finalAttrs.version}.tar.bz2";
    hash = "sha256-rwUDE+5jvBizWy4GTl3OBbJ2qvbRqiuKgs7R/i+AKOk=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    jdk_headless
    python3
  ];
  buildInputs = [
    libsamplerate
    libsndfile
    fftw
    vamp-plugin-sdk
    ladspa-header
    lv2
  ];
  makeFlags = ["AR:=$(AR)"];

  # TODO: package boost-test, so we can run the test suite. (Currently it fails
  # to find libboost_unit_test_framework.a.)
  mesonFlags = ["-Dtests=disabled"];
  doCheck = false;

  postPatch = ''
    python3 - <<'PY'
    from pathlib import Path
    import re

    ttl = Path("ladspa-lv2/rubberband.lv2/lv2-rubberband.ttl")
    text = ttl.read_text()

    port_names = [
        "latencyPort",
        "centsPort",
        "semitonesPort",
        "octavesPort",
        "crispnessPort",
        "formantPort",
        "formantPortR3",
        "wetDryPort",
        "wetDryPortR3",
    ]

    ports = {}
    for name in port_names:
        match = re.search(rf"^:{name}\n(?P<body>(?:        .*\n)*?        .* \.)\n", text, re.MULTILINE)
        if match is None:
            raise RuntimeError(f"failed to find LV2 port definition for {name}")
        body = match.group("body").rstrip()
        body = body.removesuffix(" .")
        ports[name] = f"[{body}\n                 ]"

    for name, replacement in ports.items():
        text = text.replace(f":{name} ,", f"{replacement} ,")

    ttl.write_text(text)
    PY
  '';

  meta = {
    description = "High quality software library for audio time-stretching and pitch-shifting";
    homepage = "https://breakfastquay.com/rubberband/";
    # commercial license available as well, see homepage. You'll get some more optimized routines
    license = lib.licenses.gpl2Plus;
    maintainers = [];
    platforms = lib.platforms.all;
  };
})
