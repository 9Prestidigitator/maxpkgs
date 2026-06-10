{
  lib,
  stdenv,
  fetchurl,
  requireFile,
  autoPatchelfHook,
  libX11,
  symlinkJoin,
  unzip,
  zlib,
}: let
  pluginPaths = plugins: map (plugin: plugin.default) plugins;

  mkAuburnPlugin = {
    attrName,
    archiveBase,
    description,
    homepage,
    itchSlug,
    productName,
    version,
    freeHash,
  }: let
    mkEdition = {
      archiveEdition,
      descriptionEdition,
      name,
      src,
    }:
      stdenv.mkDerivation (finalAttrs: {
        inherit src version;

        pname = "${attrName}-${name}";

        nativeBuildInputs = [
          autoPatchelfHook
          unzip
        ];

        buildInputs = [
          libX11
          stdenv.cc.cc.lib
          zlib
        ];

        dontBuild = true;
        dontStrip = true;

        unpackPhase = ''
          unzip -q "$src"
        '';

        installPhase = ''
          runHook preInstall

          cd ${archiveBase}-${archiveEdition}-${finalAttrs.version}

          mkdir -p $out/lib/clap $out/lib/lv2 $out/lib/vst $out/lib/vst3 $out/share/doc/${finalAttrs.pname}

          while IFS= read -r -d "" plugin; do
            install -Dm755 "$plugin" "$out/lib/clap/$(basename "$plugin")"
          done < <(find Linux -type f -name "*.clap" -print0)

          while IFS= read -r -d "" bundle; do
            cp -r "$bundle" $out/lib/lv2/
          done < <(find Linux -type d -name "*.lv2" -print0)

          while IFS= read -r -d "" plugin; do
            install -Dm755 "$plugin" "$out/lib/vst/$(basename "$plugin")"
          done < <(find Linux -type f -name "*.so" ! -path "*.lv2/*" ! -path "*.vst3/*" -print0)

          while IFS= read -r -d "" bundle; do
            cp -r "$bundle" $out/lib/vst3/
          done < <(find Linux -type d -name "*.vst3" -print0)

          for doc in *.pdf *.jpg *.html; do
            [ -e "$doc" ] || continue
            install -m644 -t $out/share/doc/${finalAttrs.pname} "$doc"
          done

          runHook postInstall
        '';

        meta = {
          description = "${descriptionEdition} edition of ${description}";
          inherit homepage;
          license = lib.licenses.unfree;
          maintainers = with lib.maintainers; [polygon];
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      });

    mkFree = version: hash:
      mkEdition {
        name = "free";
        archiveEdition = "FREE";
        descriptionEdition = "Free";
        src = fetchurl {
          url = "https://www.auburnsounds.com/downloads/${archiveBase}-FREE-${version}.zip";
          inherit hash;
        };
      };

    mkFull = version: hash:
      mkEdition {
        name = "full";
        archiveEdition = "FULL";
        descriptionEdition = "Paid full";
        src = requireFile rec {
          name = "${archiveBase}-FULL-${version}.zip";
          inherit hash;
          message = ''
            ${productName} FULL is a paid download distributed through itch.io.

            Download ${name} from:
              https://auburnsounds.itch.io/${itchSlug}

            Then compute its hash:
              nix hash file --type sha256 --sri /path/to/${name}

            Replace the hash for ${attrName}.full in pkgs/auburn-sounds.nix, then add the file to the Nix store:
              nix-store --add-fixed sha256 /path/to/${name}
          '';
        };
      };
  in rec {
    free = mkFree version freeHash;
    full = mkFull version lib.fakeHash;
    paid = full;
    default = free;
  };

  selene = mkAuburnPlugin {
    attrName = "selene";
    archiveBase = "Selene";
    description = "Auburn Sounds Selene algorithmic reverb audio plugin";
    homepage = "https://www.auburnsounds.com/products/Selene.html";
    itchSlug = "selene";
    productName = "Selene";
    version = "1.1";
    freeHash = "sha256-n7CwJELLgfO0Gfggf7YxBambQfiEW7T1qj+KsyA2ahI=";
  };

  graillon = mkAuburnPlugin {
    attrName = "graillon";
    archiveBase = "Graillon";
    description = "Auburn Sounds Graillon live voice changer audio plugin";
    homepage = "https://www.auburnsounds.com/products/Graillon.html";
    itchSlug = "graillon";
    productName = "Graillon";
    version = "3.2";
    freeHash = "sha256-2e0lS9asidXF5nA4Pewssaz0OnLGLr8uRAHQOf9r2hg=";
  };

  inner-pitch = mkAuburnPlugin {
    attrName = "inner-pitch";
    archiveBase = "Inner-Pitch";
    description = "Auburn Sounds Inner Pitch pitch-shifting audio plugin";
    homepage = "https://www.auburnsounds.com/products/InnerPitch.html";
    itchSlug = "innerpitch";
    productName = "Inner Pitch";
    version = "2.1";
    freeHash = "sha256-7tuzB5VOw4+HV10eGAcllkUQfYMHecNyeqkSlGVpH+w=";
  };

  lens = mkAuburnPlugin {
    attrName = "lens";
    archiveBase = "Lens";
    description = "Auburn Sounds Lens multiband compander audio plugin";
    homepage = "https://www.auburnsounds.com/products/Lens.html";
    itchSlug = "lens";
    productName = "Lens";
    version = "1.4";
    freeHash = "sha256-iF+c8O1YhObUV0VX7tZ1mYS/wkDm8x00yrLMwIVACBw=";
  };

  renegate = mkAuburnPlugin {
    attrName = "renegate";
    archiveBase = "Renegate";
    description = "Auburn Sounds Renegate gate audio plugin";
    homepage = "https://www.auburnsounds.com/products/Renegate.html";
    itchSlug = "renegate";
    productName = "Renegate";
    version = "1.6";
    freeHash = "sha256-eAcfQsrW/y2Qs2y0MdF3WL51XaGlIYrBw5QD2Jk7UG8=";
  };

  panagement = mkAuburnPlugin {
    attrName = "panagement";
    archiveBase = "Panagement";
    description = "Auburn Sounds Panagement spatialization audio plugin";
    homepage = "https://www.auburnsounds.com/products/Panagement.html";
    itchSlug = "panagement";
    productName = "Panagement";
    version = "2.8";
    freeHash = "sha256-XYz0gE2Dnel6ArvuQM3Wf6E5cYE+UGERrOqsh7ZkAHg=";
  };

  couture = mkAuburnPlugin {
    attrName = "couture";
    archiveBase = "Couture";
    description = "Auburn Sounds Couture transient shaper and distortion audio plugin";
    homepage = "https://www.auburnsounds.com/products/Couture.html";
    itchSlug = "couture";
    productName = "Couture";
    version = "1.10";
    freeHash = "sha256-KYiVdmdtGu+z6wavzYM3dRnbYepRWsaTlvri3oxbj/M=";
  };

  currentPlugins = [
    selene
    graillon
    inner-pitch
    lens
    renegate
    panagement
    couture
  ];

  mkSuite = {
    name,
    description,
    paths,
  }:
    symlinkJoin {
      inherit name paths;

      meta = {
        inherit description;
        homepage = "https://www.auburnsounds.com/index.html";
        license = lib.licenses.unfree;
        maintainers = with lib.maintainers; [9prestidigitator];
        platforms = ["x86_64-linux"];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
    };
in rec {
  inherit
    couture
    graillon
    inner-pitch
    lens
    panagement
    renegate
    selene
    ;

  free = mkSuite {
    name = "auburn-sounds-free";
    description = "Free editions of the current Auburn Sounds audio plugin suite";
    paths = pluginPaths currentPlugins;
  };

  full = mkSuite {
    name = "auburn-sounds-full";
    description = "Paid full editions of the current Auburn Sounds audio plugin suite";
    paths = [
      selene.full
      graillon.full
      inner-pitch.full
      lens.full
      renegate.full
      panagement.full
      couture.full
    ];
  };

  default = free;
}
