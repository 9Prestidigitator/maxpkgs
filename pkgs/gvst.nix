{
  lib,
  stdenv,
  autoPatchelfHook,
  curl,
  libglvnd,
  libX11,
  unzip,
  writeShellScript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gvst";
  version = "2024-09-25";

  src = stdenv.mkDerivation {
    name = "AllGVSTLinux64.zip";
    builder = writeShellScript "fetch-gvst.sh" ''
      curl=(
        ${curl}/bin/curl
        --fail
        --location
        --max-redirs 20
        --retry 3
        --silent
        --show-error
        --insecure
      )

      "''${curl[@]}" \
        --cookie-jar cookies \
        --output /dev/null \
        "https://gvst.uk/Downloads"

      "''${curl[@]}" \
        --cookie cookies \
        --cookie-jar cookies \
        --referer "https://gvst.uk/Downloads" \
        --output /dev/null \
        "https://gvst.uk/Downloads/SelectPackage"

      "''${curl[@]}" \
        --cookie cookies \
        --referer "https://gvst.uk/Downloads/SelectPackage" \
        --output "$out" \
        "https://gvst.uk/Downloads/Get/AllGVSTLinux64.zip"
    '';
    nativeBuildInputs = [curl];
    outputHashAlgo = "sha256";
    outputHash = "sha256-p8ZB9Ijfn5C5vWxcjeRgFgNHAn/9Ryu3DXbJNp/b/ig=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    libX11
    libglvnd
    stdenv.cc.cc.lib
  ];

  dontBuild = true;

  unpackPhase = ''
    unzip "$src"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 GVSTLicense.txt $out/share/doc/${finalAttrs.pname}/GVSTLicense.txt
    install -Dm755 -t $out/lib/vst/GVST *.so

    runHook postInstall
  '';

  meta = {
    description = "GVST audio effect and instrument plugin suite";
    homepage = "https://gvst.uk/";
    license = lib.licenses.unfree;
    maintainers = [];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
