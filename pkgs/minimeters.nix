{
  lib,
  stdenv,
  stdenvNoCC,
  requireFile,
  autoPatchelfHook,
  cacert,
  copyDesktopItems,
  curl,
  jq,
  libdecor,
  libglvnd,
  libX11,
  libXcursor,
  libXrandr,
  libXrender,
  libxkbcommon,
  makeWrapper,
  makeDesktopItem,
  openssl,
  unzip,
  wayland,
  writeShellScript,
  paidHash ? lib.fakeHash,
}: let
  version = "1.0.30";
  homepage = "https://minimeters.app/";

  platformInfo =
    {
      x86_64-linux = {
        demoFileName = "minimeters-linux-demo.zip";
        demoUploadId = "5758513";
        demoHash = "sha256-3LHiWL42yrj1EkcqpPfa/3KY3s9wE9+XW1KGNAQmWaE=";
        paidFileName = "minimeters-linux.zip";
      };
      aarch64-linux = {
        demoFileName = "minimeters-linux-arm64-demo.zip";
        demoUploadId = "14484397";
        demoHash = "sha256-tnnqfwusHq1IL5BC8fbhqzJOxLqeDT5Ev7Es9zDywCA=";
        paidFileName = "minimeters-linux-arm64.zip";
      };
    }
    .${
      stdenv.hostPlatform.system
    }
    or {
      demoFileName = "minimeters-linux-unsupported.zip";
      demoUploadId = "";
      demoHash = lib.fakeHash;
      paidFileName = "minimeters-linux-unsupported.zip";
    };

  platforms = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  runtimeLibraries = [
    libdecor
    libglvnd
    libX11
    libXcursor
    libXrandr
    libXrender
    libxkbcommon
    openssl
    stdenv.cc.cc.lib
    wayland
  ];

  fetchItchUpload = {
    name,
    uploadId,
    hash,
  }:
    stdenvNoCC.mkDerivation {
      inherit name;

      builder = writeShellScript "fetch-minimeters-${uploadId}.sh" ''
        set -euo pipefail

        export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

        curl=(
          ${curl}/bin/curl
          --fail
          --location
          --max-redirs 20
          --retry 3
          --silent
          --show-error
        )

        "''${curl[@]}" \
          --cookie-jar cookies \
          --output minimeters.html \
          "https://directmusic.itch.io/minimeters"

        csrf=$(sed -n 's/.*name="csrf_token" value="\([^"]*\)".*/\1/p' minimeters.html)
        if [ -z "$csrf" ]; then
          echo "Unable to find itch.io CSRF token for MiniMeters" >&2
          exit 1
        fi

        "''${curl[@]}" \
          --cookie cookies \
          --cookie-jar cookies \
          --referer "https://directmusic.itch.io/minimeters" \
          --header "X-CSRF-Token: $csrf" \
          --header "Accept: application/json" \
          --header "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
          --header "X-Requested-With: XMLHttpRequest" \
          --data-urlencode "csrf_token=$csrf" \
          --output download.json \
          "https://directmusic.itch.io/minimeters/file/${uploadId}?source=view_game&as_props=1"

        url=$(${jq}/bin/jq -r '.url // empty' download.json)
        if [ -z "$url" ]; then
          ${jq}/bin/jq -r '.errors[]?' download.json >&2
          exit 1
        fi

        "''${curl[@]}" \
          --output "$out" \
          "$url"
      '';

      nativeBuildInputs = [
        cacert
        curl
        jq
      ];

      outputHashAlgo = "sha256";
      outputHash = hash;
    };

  mkMiniMeters = {
    binaryName,
    desktopName,
    pname,
    src,
    description,
  }:
    stdenv.mkDerivation (finalAttrs: {
      inherit pname version src;

      nativeBuildInputs = [
        autoPatchelfHook
        copyDesktopItems
        makeWrapper
        unzip
      ];

      buildInputs = runtimeLibraries;

      dontConfigure = true;
      dontBuild = true;
      dontStrip = true;

      desktopItems = [
        (makeDesktopItem {
          name = finalAttrs.pname;
          exec = binaryName;
          inherit desktopName;
          icon = "minimeters";
          comment = description;
          categories = [
            "AudioVideo"
            "Audio"
          ];
          startupNotify = false;
        })
      ];

      unpackPhase = ''
        unzip -q "$src"
      '';

      installPhase = ''
        runHook preInstall

        appimage="$(find . -maxdepth 1 -type f -name "MiniMeters*.AppImage" -print -quit)"
        if [ -z "$appimage" ]; then
          echo "Unable to find MiniMeters AppImage in archive" >&2
          exit 1
        fi

        chmod +x "$appimage"
        "$appimage" --appimage-extract >/dev/null

        install -Dm755 squashfs-root/usr/bin/MiniMeters "$out/bin/${binaryName}"
        install -Dm644 squashfs-root/MiniMeters.png "$out/share/icons/hicolor/256x256/apps/minimeters.png"

        wrapProgram "$out/bin/${binaryName}" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}"

        if [ -d CLAP ]; then
          while IFS= read -r -d "" plugin; do
            install -Dm755 "$plugin" "$out/lib/clap/$(basename "$plugin")"
          done < <(find CLAP -maxdepth 1 -type f -name "*.clap" -print0)
        fi

        if [ -d VST3 ]; then
          mkdir -p "$out/lib/vst3"
          while IFS= read -r -d "" bundle; do
            cp -r "$bundle" "$out/lib/vst3/"
          done < <(find VST3 -maxdepth 1 -type d -name "*.vst3" -print0)
        fi

        runHook postInstall
      '';

      meta = {
        inherit description homepage platforms;
        license = lib.licenses.unfree;
        mainProgram = binaryName;
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
    });

  demoSrc = fetchItchUpload {
    name = platformInfo.demoFileName;
    uploadId = platformInfo.demoUploadId;
    hash = platformInfo.demoHash;
  };

  paidSrc = requireFile rec {
    name = platformInfo.paidFileName;
    hash = paidHash;
    message = ''
      MiniMeters is a paid download distributed through itch.io.

      Purchase and download ${name} from:
        https://directmusic.itch.io/minimeters

      Then compute its hash:
        nix hash file --type sha256 --sri /path/to/${name}

      Override the paidHash package argument with that hash, then add the file to the Nix store:
        nix-store --add-fixed sha256 /path/to/${name}
    '';
  };
in rec {
  demo = mkMiniMeters {
    pname = "minimeters-demo";
    binaryName = "minimeters-demo";
    desktopName = "MiniMeters Demo";
    description = "Demo edition of the MiniMeters audio metering application and plug-in suite";
    src = demoSrc;
  };

  full = mkMiniMeters {
    pname = "minimeters-full";
    binaryName = "minimeters";
    desktopName = "MiniMeters";
    description = "MiniMeters audio metering application and plug-in suite";
    src = paidSrc;
  };

  paid = full;
  default = demo;
}
