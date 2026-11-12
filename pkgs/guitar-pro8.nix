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
  archiveName = "guitar-pro.exe";
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

  # The full macOS installer contains both the signed app and the RSE banks.
  src =
    if isDarwin
    then
      fetchurl {
        name = "guitar-pro8-${finalAttrs.version}-full.pkg";
        url = "https://downloads.guitar-pro.com/gp8/stable/guitar-pro-8-setup.pkg";
        hash = "sha256-sTCF9wrtSZHqrtDOBd1wTzNlvvO5qcPwt7WDeOeTrBY=";
      }
    else
      fetchurl {
        # The public feed supplies short-lived signed URLs. Pin the resulting archive,
        # not the XML or an expiring URL; fail if the feed stops offering this release.
        name = "guitar-pro8-${finalAttrs.version}-${archiveName}";
        url = "https://cast.assets-arobas-music.com/sparkleAppCast?os=WINDOWS&channel=stable&version=0";
        hash = "sha256-iKDlGUFwXdsvvugQ/56s+/B4GPQ9lx6xGGH67YhN4+w=";
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
      bsdtar -xf unpacked/guitarpro.pkg/Payload -C payload
      cp -R "payload/Guitar Pro 8.app" "$out/Applications/"
      soundbanks="$out/Library/Application Support/Arobas Music/Soundbanks"
      mkdir -p "$soundbanks"
      bsdtar -xf unpacked/soundbank-full.pkg/Payload -C "$soundbanks"
      bank="$soundbanks/com.arobas-music.soundbank.standard"
      test -d "$bank/Contents/Resources/banks"
      test -d "$bank/Contents/Resources/sets"
      cat > "$out/bin/guitar-pro8" <<EOF
      #!/bin/sh
      exec /usr/bin/open -a "$out/Applications/Guitar Pro 8.app" "\$@" --args --soundbank-path "$bank/Contents/Resources"
      EOF
      chmod +x "$out/bin/guitar-pro8"
      substitute ${./guitar-pro8/install-soundbanks.sh} "$out/bin/guitar-pro8-install-soundbanks" \
        --subst-var-by bank "$bank"
      chmod +x "$out/bin/guitar-pro8-install-soundbanks"
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
