{
  runCommand,
  writeShellScriptBin,
  callPackage,
  guitar-pro8,
}: let
  mockWine = writeShellScriptBin "wine" ''
    printf '%s\n' "$WINEPREFIX" "$WINEARCH" "$@" > "$TEST_OUTPUT"
  '';
  package = (callPackage ../guitar-pro8.nix {wine = mockWine;}).overrideAttrs {
    src = guitar-pro8.src;
  };
in
  runCommand "guitar-pro8-installer-test" {} ''
    export HOME="$TMPDIR/home"
    export XDG_DATA_HOME="$TMPDIR/data with spaces"
    export TEST_OUTPUT="$TMPDIR/actual"
    unset WINEPREFIX WINEARCH
    ${package}/bin/guitar-pro8-install /TEST 'argument with spaces'
    printf '%s\n' "$XDG_DATA_HOME/guitar-pro8/wine" win64 '${package.src}' /TEST 'argument with spaces' > expected
    diff -u expected "$TEST_OUTPUT"
    test -d "$XDG_DATA_HOME/guitar-pro8/wine"
    export WINEPREFIX="$TMPDIR/custom prefix"
    export WINEARCH=win32
    ${package}/bin/guitar-pro8-install
    printf '%s\n' "$WINEPREFIX" win32 '${package.src}' > expected
    diff -u expected "$TEST_OUTPUT"
    test -f ${package}/share/guitar-pro8/guitar-pro-8-setup.exe
    touch "$out"
  ''
