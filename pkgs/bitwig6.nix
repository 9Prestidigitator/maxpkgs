{
  alsa-lib,
  atk,
  autoPatchelfHook,
  bubblewrap,
  cairo,
  dpkg,
  fetchurl,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  lcms,
  lib,
  libglvnd,
  libjack2,
  libjpeg8,
  libnghttp2,
  libudev-zero,
  libx11,
  libxcb,
  libxcb-util,
  libxcb-wm,
  libxcursor,
  libxkbcommon,
  libxtst,
  makeBinaryWrapper,
  pango,
  pipewire,
  stdenv,
  undmg,
  vulkan-loader,
  wrapGAppsHook3,
  writeShellScript,
  xcb-imdkit,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: let
  bitwigVersion = "6.1 Beta 7";
  urlVersion = lib.replaceStrings [" "] ["%20"] bitwigVersion;
in {
  pname = "bitwig-studio6";
  version = "6.1-beta7";

  src = fetchurl (
    if stdenv.hostPlatform.isDarwin
    then {
      name = "bitwig-studio-${finalAttrs.version}.dmg";
      url = "https://www.bitwig.com/dl/Bitwig%20Studio/${urlVersion}/installer_mac/";
      hash = "sha256-iKUIWRv0e4y8mWAM7zTTlY0pcM/v0bbmW6gmibuREFY=";
    }
    else {
      name = "bitwig-studio-${finalAttrs.version}.deb";
      url = "https://www.bitwig.com/dl/Bitwig%20Studio/${urlVersion}/installer_linux/";
      hash = "sha256-9xd+eR49v/a9mcaac2Qe96eRRYV/BKRUPdG0dPzCOHc=";
    }
  );

  strictDeps = true;

  sourceRoot =
    if stdenv.hostPlatform.isDarwin
    then "."
    else "root";

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
      dpkg
      makeBinaryWrapper
      wrapGAppsHook3
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      undmg
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    atk
    cairo
    freetype
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    lcms
    libglvnd
    (lib.getLib stdenv.cc.cc)
    libjack2
    libjpeg8
    libnghttp2
    libudev-zero
    libx11
    libxcb
    libxcb-util
    libxcb-wm
    libxcursor
    libxkbcommon
    libxtst
    pango
    pipewire
    vulkan-loader
    xcb-imdkit
    zlib
    alsa-lib
  ];

  dontWrapGApps = true; # we only want $gappsWrapperArgs here

  installPhase =
    if stdenv.hostPlatform.isDarwin
    then ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"
      cp -R "Bitwig Studio.app" "$out/Applications/"
      ln -s "$out/Applications/Bitwig Studio.app/Contents/MacOS/BitwigStudio" "$out/bin/bitwig-studio"

      runHook postInstall
    ''
    else ''
      runHook preInstall

      mkdir "$out"
      cp -r usr/share "$out"
      cp -r opt/bitwig-studio "$out"/libexec

      # Bitwig includes a copy of libxcb-imdkit.
      # Removing it will force it to use our version.
      rm "$out"/libexec/lib/bitwig-studio/libxcb-imdkit.so.1

      runHook postInstall
    '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux (let
    wrapper = writeShellScript "bitwig-studio" ''
      set -e

      currentDir="$(cd "$(dirname "$0")" && pwd)"
      outDir="$(cd "$currentDir/.." && pwd)"

      TMPDIR="$(mktemp --directory)"
      cp -r "$outDir"/libexec/resources/VampTransforms "$TMPDIR"
      chmod -R u+w "$TMPDIR/VampTransforms"

      bwrap \
        --bind / / \
        --bind "$TMPDIR"/VampTransforms "$outDir"/libexec/resources/VampTransforms \
        --dev-bind /dev /dev \
        "$outDir"/libexec/bitwig-studio \
        || true

      rm -rf "$TMPDIR"
    '';
  in ''
    for e in "$out"/libexec/bin/*gtk*; do
      if [ -f "$e" ] && [ -x "$e" ]; then
        wrapProgram "$e" "''${gappsWrapperArgs[@]}"
      fi
    done

    install -D ${wrapper} "$out"/bin/bitwig-studio
    wrapProgram "$out"/bin/bitwig-studio \
      --prefix PATH : ${lib.makeBinPath [bubblewrap]}
  '');

  meta = {
    description = "Digital audio workstation";
    longDescription = ''
      Bitwig Studio is a multi-platform music-creation system for
      production, performance and DJing, with a focus on flexible
      editing tools and a super-fast workflow.
    '';
    homepage = "https://www.bitwig.com/";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux" "aarch64-darwin"];
    maintainers = with lib.maintainers; [
      bfortz
      eleina
      michalrus
      mrVanDalo
    ];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "bitwig-studio";
  };
})
