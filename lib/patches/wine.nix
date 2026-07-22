{pkgs}: let
  # This patch lets yabridge use current Wine staging releases without the
  # cursor-window placement regression that previously required Wine 9.21.
  # Ended up resulting in a lot of new issues when opening and closing plugins,
  # so I'm probably not going to keep using this.
  wineStagingPatched = (pkgs.wineWow64Packages.base.override {wineRelease = "staging";}).overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        (pkgs.fetchurl {
          url = "https://gitlab.winehq.org/-/project/5/uploads/dea8a1e711846f7e7642c16eacd284b4/bug51357.patch";
          hash = "sha256-ZfW94gCDLGauKEZOid7ndQsaPA6SVGk22CQ3EBWAPm8=";
        })
      ];
  });

  wineSetPatched = pkgs.wineWow64Packages // {yabridge = wineStagingPatched;};

  yabridgePatched = pkgs.yabridge.override {wineWow64Packages = wineSetPatched;};
  yabridgectlPatched = pkgs.yabridgectl.override {
    wineWow64Packages = wineSetPatched;
    yabridge = yabridgePatched;
  };
in {
  inherit wineStagingPatched yabridgePatched yabridgectlPatched;
}
