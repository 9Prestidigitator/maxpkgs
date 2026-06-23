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
  pname = "mixlocker";
  version = "1.0.7";

  src = fetchurl {
    url = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/MixLockerLinux.zip";
    hash = "sha256-oao+wSmiF2vjbw9N8WFGr/c2NwGfUkTsa+4MhGiyYsk=";
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
    find MixLockerData -name ".DS_Store" -delete

    mkdir -p $out/bin $out/lib/lv2 $out/lib/vst3 $out/"Audio Assault" $out/share/doc/$pname
    cp -r "Mix Locker.lv2" $out/lib/lv2/
    cp -r "Mix Locker.vst3" $out/lib/vst3/
    cp -r MixLockerData $out/"Audio Assault"/
    install -Dm644 "How To Install.txt" $out/share/doc/$pname/"How To Install.txt"

    cat > $out/bin/mix-locker-install-data <<EOF
    #!/usr/bin/env sh
    data_home="\$HOME/Audio Assault/PluginData/Audio Assault/MixLockerData"
    legacy_data_home="\$HOME/Audio Assault/PluginData/AudioAssault/MixLockerData"
    mkdir -p "\$data_home"
    ${coreutils}/bin/cp -rsf --no-preserve=mode "$out/Audio Assault/MixLockerData"/. "\$data_home"/
    mkdir -p "\$(dirname "\$legacy_data_home")"
    if [ ! -e "\$legacy_data_home" ] || [ -L "\$legacy_data_home" ]; then
      ${coreutils}/bin/ln -sfn "\$data_home" "\$legacy_data_home"
    fi
    EOF
    chmod +x $out/bin/mix-locker-install-data

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
      $out/lib/lv2/"Mix Locker.lv2"/"Mix Locker.so" \
      $out/lib/vst3/"Mix Locker.vst3"/Contents/x86_64-linux/"Mix Locker.so"
    do
      patchelf --add-rpath ${libraryPath} "$plugin"
    done
  '';

  meta = with lib; {
    description = "AudioAssault Mix Locker mixing suite plugin";
    homepage = "https://audioassault.mx/getmixlocker";
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [polygon];
    license = licenses.unfree;
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
