{pkgs}: let
  # Keep the Wine source and staging patches on the same release until nixpkgs
  # catches up. Updating only src would leave the old staging prePatch in place.
  version = "11.18";
  staging = pkgs.fetchFromGitHub {
    owner = "wine-staging";
    repo = "wine-staging";
    tag = "v${version}";
    hash = "sha256-KZCkra0y3XFNrbD2lZ+YUCLyq1POC30Sd4sGCJZuwgQ=";
  };

  # This patch lets yabridge use current Wine staging releases without the
  # cursor-window placement regression that previously required Wine 9.21.
  # Ended up resulting in a lot of new issues when opening and closing plugins,
  # so I'm probably not going to keep using this.
  wineStagingPatched = (pkgs.wineWow64Packages.base.override {wineRelease = "staging";}).overrideAttrs (old: {
    inherit version;
    src = pkgs.fetchurl {
      url = "https://dl.winehq.org/wine/source/11.x/wine-${version}.tar.xz";
      hash = "sha256-xigvbU2uzxHzq5+aK2xZj2e+fijDY7osroo8RLYR56Q=";
    };
    prePatch = pkgs.lib.replaceStrings ["${old.src.staging}"] ["${staging}"] old.prePatch;
    meta = old.meta // {inherit version;};
    # Rebase bug51357.patch onto the POINT-based map_event_coords in Wine 11.18.
    # https://bugs.winehq.org/show_bug.cgi?id=51357
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace dlls/winex11.drv/mouse.c \
          --replace-fail '    else if (event_root == root_window) dst = root_to_virtual_screen( root.x, root.y );' \
          '    /* Use window-relative coordinates for embedded yabridge windows (Wine bug 51357). */'
      '';
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
