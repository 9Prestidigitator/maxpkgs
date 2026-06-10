{
  lib,
  stdenv,
  fetchurl,
  requireFile,
  autoPatchelfHook,
  libX11,
  unzip,
}: let
  mkInnerPitch = {
    archiveEdition,
    descriptionEdition,
    name,
    src,
    version,
  }:
    stdenv.mkDerivation (finalAttrs: {
      inherit src version;

      pname = "inner-pitch-${name}";

      nativeBuildInputs = [
        autoPatchelfHook
        unzip
      ];

      buildInputs = [
        libX11
        stdenv.cc.cc.lib
      ];

      dontBuild = true;
      dontStrip = true;

      unpackPhase = ''
        unzip -q "$src"
      '';

      installPhase = ''
        runHook preInstall

        cd Inner-Pitch-${archiveEdition}-${finalAttrs.version}

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
        description = "${descriptionEdition} edition of Auburn Sounds Inner Pitch pitch-shifting audio plugin";
        homepage = "https://www.auburnsounds.com/products/InnerPitch.html";
        license = lib.licenses.unfree;
        maintainers = with lib.maintainers; [polygon];
        platforms = ["x86_64-linux"];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
    });

  mkFree = version: hash:
    mkInnerPitch {
      name = "free";
      archiveEdition = "FREE";
      descriptionEdition = "Free";
      inherit version;
      src = fetchurl {
        url = "https://www.auburnsounds.com/downloads/Inner-Pitch-FREE-${version}.zip";
        inherit hash;
      };
    };

  mkFull = version: hash:
    mkInnerPitch {
      name = "full";
      archiveEdition = "FULL";
      descriptionEdition = "Paid full";
      inherit version;
      src = requireFile rec {
        name = "Inner-Pitch-FULL-${version}.zip";
        inherit hash;
        message = ''
          Inner Pitch FULL is a paid download distributed through itch.io.

          Download ${name} from:
            https://auburnsounds.itch.io/innerpitch

          Then compute its hash:
            nix hash file --type sha256 --sri /path/to/${name}

          Replace the hash for full_2 in pkgs/inner-pitch.nix, then add the file to the Nix store:
            nix-store --add-fixed sha256 /path/to/${name}
        '';
      };
    };

  version2 = "2.1";
in rec {
  free = mkFree version2 "sha256-7tuzB5VOw4+HV10eGAcllkUQfYMHecNyeqkSlGVpH+w=";
  full = mkFull version2 lib.fakeHash;
  default = free;
}
