{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  unzip,
  makeDesktopItem,
  steam-run-free,
  alsa-lib,
  libX11,
  curl,
  openssl,
  libGL,
  freetype,
  glibc_multi,
  patchelf,
  coreutils,
  cpio,
  p7zip,
}:
stdenv.mkDerivation {
  pname = "Amp Locker";
  version = "1.5.51";

  src = fetchurl (
    if stdenv.hostPlatform.isDarwin
    then {
      url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/AmpLockerMac.pkg";
      hash = "sha256-Dmr7o6AFvFGTZSKjQ5KNw2p026/VrkM0/dUSmQS0mB0=";
    }
    else {
      url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/AmpLockerLinux.zip";
      hash = "sha256-ZHh6Kayc0bZG3sVC/L1xpXXzWGr/eVtzlze9By7RedY=";
    }
  );

  nativeBuildInputs =
    [coreutils]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      copyDesktopItems
      patchelf
      unzip
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cpio
      p7zip
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    steam-run-free
    alsa-lib
    libX11
    curl
    openssl
    libGL
    freetype
    glibc_multi
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontUnpack = true;

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "amp-locker";
      exec = "Amp_Locker_Standalone";
      desktopName = "Amp Locker";
      icon = "amp-locker";
      comment = "AudioAssault Amp Locker";
      categories = [
        "AudioVideo"
        "Audio"
      ];
      startupNotify = false;
    })
  ];

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      7z x "$src" >/dev/null
      mkdir payload
      cd payload
      for archive in ../Amp_Locker_{AU,Data,Standalone,VST3}.pkg/Payload; do
        gzip -dc "$archive" | cpio -idm --quiet
      done

      mkdir -p \
        "$out/Applications" \
        "$out/bin" \
        "$out/Library/Audio/Plug-Ins/Components" \
        "$out/Library/Audio/Plug-Ins/VST3" \
        "$out/share/audio-assault"
      cp -R Applications/*.app "$out/Applications/"
      cp -R Library/Audio/Plug-Ins/Components/*.component "$out/Library/Audio/Plug-Ins/Components/"
      cp -R Library/Audio/Plug-Ins/VST3/*.vst3 "$out/Library/Audio/Plug-Ins/VST3/"
      cp -R 'Users/Shared/Audio Assault/AmpLockerData' "$out/share/audio-assault/"

      app=$(find "$out/Applications" -type d -name '*.app' -print -quit)
      executable=$(find "$app/Contents/MacOS" -type f -perm -0100 -print -quit)
      ln -s "$executable" "$out/bin/Amp_Locker_Standalone"

      cat > "$out/bin/amp-locker-install-data" <<EOF
      #!/bin/sh
      destination='/Users/Shared/Audio Assault/AmpLockerData'
      mkdir -p "\$destination"
      ${coreutils}/bin/cp -R "$out/share/audio-assault/AmpLockerData/." "\$destination/"
      EOF
      chmod +x "$out/bin/amp-locker-install-data"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      unzip -q "$src" -d .
      rm -rf __MACOSX
      mkdir -p $out
      mkdir -p $out/bin
      mkdir -p $out/lib/lv2
      mkdir -p $out/lib/vst3
      mkdir -p $out/"Audio Assault"
      cp -r "Amp Locker Standalone" $out/bin/".Amp_Locker_Standalone_unwrapped"
      cp -r "Amp Locker.lv2" $out/lib/lv2/
      cp -r "Amp Locker.vst3" $out/lib/vst3/
      cp -r "AmpLockerData" $out/"Audio Assault"/
      install -Dm644 ${../assets/amp-locker.svg} $out/share/icons/hicolor/scalable/apps/amp-locker.svg

      # Wrap the standalone with steam-run, it seems to segfault otherwise trying to access FHS paths
      cat > $out/bin/Amp_Locker_Standalone <<EOF
      #!/usr/bin/env sh
      data_home="\$HOME/Audio Assault/PluginData/Audio Assault/AmpLockerData"
      mkdir -p "\$data_home"
      ${coreutils}/bin/ln -sfn "$out/Audio Assault/AmpLockerData/newgfx.dat" "\$data_home/newgfx.dat"
      ${coreutils}/bin/cp -rsf --no-preserve=mode "$out/Audio Assault/AmpLockerData"/. "\$data_home"/

      ${steam-run-free}/bin/steam-run "$out/bin/.Amp_Locker_Standalone_unwrapped" "\$@"
      EOF
      chmod +x $out/bin/Amp_Locker_Standalone

      runHook postInstall
    '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux (let
    libraryPath = lib.makeLibraryPath [
      alsa-lib
      libX11
      stdenv.cc.cc.lib
      curl
      openssl
      libGL
      freetype
      glibc_multi
    ];
  in ''
    for plugin in \
      $out/bin/.Amp_Locker_Standalone_unwrapped \
      $out/lib/lv2/"Amp Locker.lv2"/"Amp Locker.so" \
      $out/lib/vst3/"Amp Locker.vst3"/Contents/x86_64-linux/"Amp Locker.so"
    do
      patchelf --add-rpath ${libraryPath} "$plugin"
    done
  '');

  meta = with lib; {
    description = "AudioAssault Amp Locker";
    homepage = "https://audioassault.mx/";
    platforms = ["x86_64-linux" "aarch64-darwin"];
    maintainers = with maintainers; [polygon];
    mainProgram = "Amp_Locker_Standalone";
    license = licenses.unfree;
  };
}
