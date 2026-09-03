{
  alsa-lib,
  autoPatchelfHook,
  cpio,
  curl,
  fetchurl,
  fontconfig,
  freetype,
  gtk3,
  lib,
  libGL,
  libX11,
  libXcomposite,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr,
  libXrender,
  libjack2,
  libsysprof-capture,
  libxkbcommon,
  patchelf,
  pcre2,
  stdenv,
  util-linux,
  webkitgtk_4_1,
  xar,
}: let
  isLinux = stdenv.hostPlatform.isLinux;
  isDarwin = stdenv.hostPlatform.isDarwin;
in
  stdenv.mkDerivation {
    pname = "tone3000-plugin";
    version = "0.0.4";

    src =
      if isLinux
      then
        fetchurl {
          url = "https://github.com/tone-3000/tone3000-plugin/releases/download/v0.0.4/TONE3000-v0.0.4-linux-x64.tar.gz";
          hash = "sha256-lscFVYygBYzgWSDAyU1fhBmSYu8L3SV7kmacBb8Np5k=";
        }
      else
        fetchurl {
          url = "https://github.com/tone-3000/tone3000-plugin/releases/download/v0.0.4/TONE3000-v0.0.4-macos-universal.pkg";
          hash = "sha256-yTE6xBBUwsBBkDGfqVmUqGC+T/5tf8uv0AgbwZRs+xA=";
        };

    dontBuild = true;

    buildInputs = lib.optionals isLinux [
      alsa-lib
      curl
      fontconfig
      freetype
      gtk3
      libGL
      libX11
      libXcomposite
      libXcursor
      libXext
      libXinerama
      libXrandr
      libXrender
      libjack2
      libsysprof-capture
      libxkbcommon
      pcre2
      util-linux
      webkitgtk_4_1
    ];

    nativeBuildInputs =
      lib.optionals isLinux [
        autoPatchelfHook
        patchelf
      ]
      ++ lib.optionals isDarwin [
        cpio
        xar
      ];

    unpackPhase =
      if isLinux
      then ''
        mkdir source
        tar --extract --gzip --file "$src" --strip-components=1 --directory source
      ''
      else ''
        mkdir pkg source
        xar --extract --file "$src" --directory pkg
        for component in _clap.pkg _vst3.pkg; do
          gzip --decompress --stdout "pkg/$component/Payload" \
            | (cd source && cpio --extract --make-directories --quiet)
        done
      '';

    sourceRoot = "source";

    installPhase =
      if isLinux
      then ''
        install -Dm755 TONE3000.clap "$out/lib/clap/TONE3000.clap"
        install -d "$out/lib/lv2" "$out/lib/vst3"
        cp -R TONE3000.lv2 "$out/lib/lv2/"
        cp -R TONE3000.vst3 "$out/lib/vst3/"
        install -d "$out/share/tone3000"
        cp -R factory-presets "$out/share/tone3000/"
      ''
      else ''
        install -d \
          "$out/Library/Audio/Plug-Ins/CLAP" \
          "$out/Library/Audio/Plug-Ins/VST3"
        cp -R TONE3000.clap "$out/Library/Audio/Plug-Ins/CLAP/"
        cp -R TONE3000.vst3 "$out/Library/Audio/Plug-Ins/VST3/"
      '';

    preFixup = lib.optionalString isLinux ''
      runtimeLibraryPath=${lib.makeLibraryPath [
        alsa-lib
        curl
        fontconfig
        freetype
        gtk3
        libGL
        libX11
        libXcomposite
        libXcursor
        libXext
        libXinerama
        libXrandr
        libXrender
        libjack2
        libsysprof-capture
        libxkbcommon
        pcre2
        util-linux
        webkitgtk_4_1
      ]}

      tone3000AddRuntimeLibraryPath() {
        for plugin in \
          "$out/lib/clap/TONE3000.clap" \
          "$out/lib/lv2/TONE3000.lv2/libTONE3000.so" \
          "$out/lib/vst3/TONE3000.vst3/Contents/x86_64-linux/TONE3000.so"; do
          patchelf --add-rpath "$runtimeLibraryPath" "$plugin"
        done
      }
      postFixupHooks+=(tone3000AddRuntimeLibraryPath)
    '';

    doInstallCheck = true;
    installCheckPhase =
      if isLinux
      then ''
        test -s "$out/lib/clap/TONE3000.clap"
        test -s "$out/lib/lv2/TONE3000.lv2/libTONE3000.so"
        test -s "$out/lib/vst3/TONE3000.vst3/Contents/x86_64-linux/TONE3000.so"
        test -s "$out/lib/vst3/TONE3000.vst3/Contents/Resources/moduleinfo.json"
      ''
      else ''
        test -s "$out/Library/Audio/Plug-Ins/CLAP/TONE3000.clap/Contents/MacOS/TONE3000"
        test -s "$out/Library/Audio/Plug-Ins/VST3/TONE3000.vst3/Contents/MacOS/TONE3000"
        test -s "$out/Library/Audio/Plug-Ins/VST3/TONE3000.vst3/Contents/Resources/moduleinfo.json"
      '';

    meta = {
      description = "NAM and impulse-response loader integrated with TONE3000";
      homepage = "https://github.com/tone-3000/tone3000-plugin";
      changelog = "https://github.com/tone-3000/tone3000-plugin/releases/tag/v0.0.4";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    };
  }
