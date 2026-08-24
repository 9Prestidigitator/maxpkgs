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
  cpio,
  p7zip,
}:
stdenv.mkDerivation {
  pname = "drumlocker";
  version = "1.0.3";

  src = fetchurl (
    if stdenv.hostPlatform.isDarwin
    then {
      url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/DrumLockerMac.pkg";
      hash = "sha256-DsXuv2DRW2jLolpbn+zByA6f2sgs+/w4prg1HasHHzM=";
    }
    else {
      url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/DrumLockerLinux.zip";
      hash = "sha256-YPf3ZCVPP4qgVPdj0t5odSQLK1KhnwzrPuJIHF90tL0=";
    }
  );

  nativeBuildInputs =
    [coreutils]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      unzip
      patchelf
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cpio
      p7zip
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    curl
    freetype
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontUnpack = true;

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      7z x "$src" >/dev/null
      mkdir payload
      cd payload
      for archive in ../Drum_Locker_{AU,Data,VST3}.pkg/Payload; do
        gzip -dc "$archive" | cpio -idm --quiet
      done

      mkdir -p \
        "$out/bin" \
        "$out/Library/Audio/Plug-Ins/Components" \
        "$out/Library/Audio/Plug-Ins/VST3" \
        "$out/share/audio-assault"
      cp -R Library/Audio/Plug-Ins/Components/*.component "$out/Library/Audio/Plug-Ins/Components/"
      cp -R Library/Audio/Plug-Ins/VST3/*.vst3 "$out/Library/Audio/Plug-Ins/VST3/"
      cp -R 'Users/Shared/Audio Assault/DrumLockerData' "$out/share/audio-assault/"

      cat > "$out/bin/drum-locker-install-data" <<EOF
      #!/bin/sh
      destination='/Users/Shared/Audio Assault/DrumLockerData'
      mkdir -p "\$destination"
      ${coreutils}/bin/cp -R "$out/share/audio-assault/DrumLockerData/." "\$destination/"
      EOF
      chmod +x "$out/bin/drum-locker-install-data"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      unzip -q "$src" -d .
      rm -rf __MACOSX
      find DrumLockerData "Drum Locker.vst3" -name ".DS_Store" -delete

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

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux (let
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
  '');

  meta = with lib; {
    description = "AudioAssault Drum Locker drum sample library player plugin";
    homepage = "https://audioassault.mx/getdrumlocker";
    platforms = ["x86_64-linux" "aarch64-darwin"];
    license = licenses.unfree;
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
