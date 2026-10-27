{
  runCommand,
  stdenv,
  lv2,
  libx11,
  xorg-server,
  drumgizmo,
}:
runCommand "drumgizmo-lv2-resize-test" {
  nativeBuildInputs = [stdenv.cc xorg-server];
  buildInputs = [lv2 libx11];
} ''
  c++ -std=c++17 -UNDEBUG ${./test-lv2-resize.cc} -o test-lv2-resize -lX11 -ldl -pthread
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME"
  Xvfb -displayfd 3 -screen 0 1280x1024x24 3>display-number >xvfb.log 2>&1 &
  xvfb_pid=$!
  trap 'kill "$xvfb_pid"' EXIT
  for attempt in $(seq 1 100); do
    test -s display-number && break
    kill -0 "$xvfb_pid"
    sleep 0.1
  done
  test -s display-number
  export DISPLAY=":$(cat display-number)"
  ./test-lv2-resize ${drumgizmo}/lib/lv2/drumgizmo.lv2
  touch "$out"
''
