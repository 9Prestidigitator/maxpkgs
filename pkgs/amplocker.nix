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
}:
stdenv.mkDerivation {
  pname = "Amp Locker";
  version = "1.5.1";

  src = fetchurl {
    url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/AmpLockerLinux.zip";
    sha256 = "sha256-LSKf6WESr/WUIrbzsW1D0XKC+UFD6ybK1XSXfSV4EmQ=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    unzip
    patchelf
    coreutils
  ];

  buildInputs = [
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

  desktopItems = [
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

  installPhase = ''
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

  preFixup = let
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
  '';

  meta = with lib; {
    description = "AudioAssault Amp Locker";
    homepage = "https://audioassault.mx/";
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [polygon];
    mainProgram = "Amp_Locker_Standalone";
    license = licenses.unfree;
  };
}
