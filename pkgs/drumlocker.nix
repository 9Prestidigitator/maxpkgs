{
  lib,
  stdenv,
  fetchurl,
  unzip,
  alsa-lib,
  curl,
  freetype,
  patchelf,
  coreutils,
}:
stdenv.mkDerivation {
  pname = "drumlocker";
  version = "1.0.2";

  src = fetchurl {
    url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/DrumLockerLinux.zip";
    hash = "sha256-fX6k5C64wNlHK1QsrdClitWlFR33jymEdVO7QIVFNGs=";
  };

  nativeBuildInputs = [
    unzip
    patchelf
    coreutils
  ];

  buildInputs = [
    alsa-lib
    curl
    freetype
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    unzip -q "$src" -d .
    rm -rf __MACOSX

    mkdir -p $out/bin $out/lib/lv2 $out/lib/vst3 $out/"Audio Assault" $out/share/doc/$pname
    cp -r "Drum Locker.lv2" $out/lib/lv2/
    cp -r "Drum Locker.vst3" $out/lib/vst3/
    cp -r DrumLockerData $out/"Audio Assault"/
    install -Dm644 "How To Install.txt" $out/share/doc/$pname/"How To Install.txt"

    cat > $out/bin/drum-locker-install-data <<EOF
    #!/usr/bin/env sh
    data_home="\$HOME/Audio Assault/PluginData/Audio Assault/DrumLockerData"
    mkdir -p "\$data_home"
    ${coreutils}/bin/cp -rsf --no-preserve=mode "$out/Audio Assault/DrumLockerData"/. "\$data_home"/
    EOF
    chmod +x $out/bin/drum-locker-install-data

    runHook postInstall
  '';

  preFixup = let
    libraryPath = lib.makeLibraryPath [
      alsa-lib
      stdenv.cc.cc.lib
      curl
      freetype
    ];
  in ''
    for plugin in \
      $out/lib/lv2/"Drum Locker.lv2"/"Drum Locker.so" \
      $out/lib/vst3/"Drum Locker.vst3"/Contents/x86_64-linux/"Drum Locker.so"
    do
      patchelf --add-rpath ${libraryPath} "$plugin"
    done
  '';

  meta = with lib; {
    description = "AudioAssault Drum Locker drum sample library player plugin";
    homepage = "https://audioassault.mx/getdrumlocker";
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [polygon];
    license = licenses.unfree;
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
