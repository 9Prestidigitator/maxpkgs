{
  lib,
  stdenvNoCC,
  fetchurl,
  python3,
  cacert,
  libarchive,
  coreutils,
  writeShellScript,
  wineWow64Packages,
  wine ? wineWow64Packages.stable,
  callPackage,
}:
stdenvNoCC.mkDerivation (finalAttrs: let
  isDarwin = stdenvNoCC.hostPlatform.isDarwin;
  upstreamOS =
    if isDarwin
    then "MACOS"
    else "WINDOWS";
  archiveName =
    if isDarwin
    then "guitar-pro.tar.gz"
    else "guitar-pro.exe";
  installer = writeShellScript "guitar-pro8-install" ''
    set -eu
    export WINEPREFIX="''${WINEPREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/guitar-pro8/wine}"
    export WINEARCH="''${WINEARCH:-win64}"
    ${coreutils}/bin/mkdir -p "$WINEPREFIX"
    exec ${wine}/bin/wine ${finalAttrs.src} "$@"
  '';
in {
  pname = "guitar-pro8";
  version = "8.1.5-31";

  # The public feed supplies short-lived signed URLs. Pin the resulting archive,
  # not the XML or an expiring URL; fail if the feed stops offering this release.
  src = fetchurl {
    name = "guitar-pro8-${finalAttrs.version}-${archiveName}";
    url = "https://cast.assets-arobas-music.com/sparkleAppCast?os=${upstreamOS}&channel=stable&version=0";
    hash =
      if isDarwin
      then "sha256-YUg/5SrwEx3xcZenC7NUXpGIZ54QpRZm+91ejU4qlsU="
      else "sha256-iKDlGUFwXdsvvugQ/56s+/B4GPQ9lx6xGGH67YhN4+w=";
    downloadToTemp = true;
    nativeBuildInputs = [python3];
    postFetch = ''
      python3 ${./guitar-pro8/select-download.py} "$downloadedFile" \
        '${finalAttrs.version}' '${archiveName}' > installer-url
      read -r installer_url < installer-url
      curl --fail --location --retry 3 --cacert ${cacert}/etc/ssl/certs/ca-bundle.crt \
        --output "$out" "$installer_url"
    '';
  };

  nativeBuildInputs = lib.optionals isDarwin [libarchive];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Preserve the vendor's signed app bundle and the Windows installer bytes.
  dontFixup = true;

  installPhase =
    if isDarwin
    then ''
      runHook preInstall
      mkdir -p unpacked payload "$out/Applications" "$out/bin"
      bsdtar -xf "$src" -C unpacked
      bsdtar -xf unpacked/GuitarPro8.pkg -C unpacked guitarpro.pkg/Payload
      bsdtar -xf unpacked/guitarpro.pkg/Payload -C payload
      cp -R "payload/Guitar Pro 8.app" "$out/Applications/"
      cat > "$out/bin/guitar-pro8" <<EOF
      #!/bin/sh
      exec /usr/bin/open -a "$out/Applications/Guitar Pro 8.app" "\$@"
      EOF
      chmod +x "$out/bin/guitar-pro8"
      runHook postInstall
    ''
    else ''
      runHook preInstall
      mkdir -p "$out/bin" "$out/share/guitar-pro8"
      ln -s "$src" "$out/share/guitar-pro8/guitar-pro-8-setup.exe"
      ln -s ${installer} "$out/bin/guitar-pro8-install"
      runHook postInstall
    '';

  passthru.tests = lib.optionalAttrs stdenvNoCC.hostPlatform.isLinux {
    installer = callPackage ./guitar-pro8/test-installer.nix {
      guitar-pro8 = finalAttrs.finalPackage;
    };
  };

  meta = {
    description =
      if isDarwin
      then "Guitar Pro 8 tablature and score editor"
      else "Guitar Pro 8 Windows installer with a Wine installation helper";
    homepage = "https://www.guitar-pro.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"];
    mainProgram =
      if isDarwin
      then "guitar-pro8"
      else "guitar-pro8-install";
  };
})
