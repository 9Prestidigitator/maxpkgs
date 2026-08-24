{
  lib,
  stdenv,
  coreutils,
  fetchFromGitHub,
  fetchPypi,
  makeWrapper,
  python3,
  ffmpeg,
  rubberband,
  tk,
}: let
  pythonEnv = python3.withPackages (ps: let
    kthread = ps.buildPythonPackage rec {
      pname = "kthread";
      version = "0.2.3";
      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-kOGU5qf/kDBAxBM9PqkDfJCMQpa/X1gsf9z2MloE+bQ=";
      };

      doCheck = false;
    };

    diffq = ps.buildPythonPackage rec {
      pname = "diffq";
      version = "0.2.3";
      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-it2HEOYhTUdFQ5/sPT4iWhv73F7mq9zC9izArkIWt1c=";
      };

      nativeBuildInputs = [ps.cython];

      propagatedBuildInputs = with ps; [
        numpy
        torch
      ];

      doCheck = false;
    };

    matchering = ps.buildPythonPackage rec {
      pname = "matchering";
      version = "2.0.6";
      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-aD9f92saLx6FLHkQjPzP2rS6+QE1epfThVW02l1cWiU=";
      };

      propagatedBuildInputs = with ps; [
        librosa
        matplotlib
        numpy
        scipy
        soundfile
        statsmodels
      ];

      doCheck = false;
    };

    onnx2pytorch = ps.buildPythonPackage rec {
      pname = "onnx2pytorch";
      version = "0.5.1";
      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-XD3fAEg45neTgXdRr/tCbXeVUpDkc7SSoFj8btzujRQ=";
      };

      propagatedBuildInputs = with ps; [
        onnx
        torch
        torchvision
      ];

      doCheck = false;
    };
  in
    with ps; [
      audioread
      cryptography
      diffq
      einops
      julius
      kthread
      librosa
      matchering
      ml-collections
      natsort
      numpy
      omegaconf
      onnx
      onnx2pytorch
      onnxruntime
      opencv4
      pillow
      playsound
      psutil
      pydub
      pyglet
      pyperclip
      pytorch-lightning
      pyyaml
      resampy
      samplerate
      scipy
      screeninfo
      soundfile
      torch
      tqdm
      wget
    ]);
in
  stdenv.mkDerivation {
    pname = "ultimate-vocal-remover-gui";
    version = "5.6.0";

    src = fetchFromGitHub {
      owner = "Anjok07";
      repo = "ultimatevocalremovergui";
      rev = "a897c05a82b1d6bd5979911535cebe248315f5ae";
      hash = "sha256-2FV7qO40LcyJTrHiWeCzAPvelcgGc+InrsXv9/QGLkA=";
    };

    nativeBuildInputs = [makeWrapper];

    postPatch = ''
      substituteInPlace UVR.py \
        --replace-fail "'GOTHIC.ttf'" "'GOTHIC.TTF'" \
        --replace-fail "size=(self.winfo_width(), 9999)" "size=(self.main_window_width, 9999)" \
        --replace-fail 'self.lastest_version = self.online_data["current_version_linux"]' "self.lastest_version = current_patch"

      substituteInPlace separate.py \
        --replace-fail "librosa.load(audio_file, bp['sr'], False, dtype=np.float32, res_type=wav_resolution)" "librosa.load(audio_file, sr=bp['sr'], mono=False, dtype=np.float32, res_type=wav_resolution)"

      substituteInPlace gui_data/app_size_values.py \
        --replace-fail "Image.ANTIALIAS" "Image.Resampling.LANCZOS"

      substituteInPlace gui_data/tkinterdnd2/TkinterDnD.py \
        --replace-fail "from tkinter import tix" "tix = None" \
        --replace-fail "class TixTk(tix.Tk, DnDWrapper):" "class TixTk(tkinter.Tk, DnDWrapper):" \
        --replace-fail "        tix.Tk.__init__(self, *args, **kw)" "        tkinter.Tk.__init__(self, *args, **kw)"
    '';

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      appdir="$out/share/ultimate-vocal-remover-gui"
      mkdir -p "$appdir" "$out/bin" "$out/share/applications" "$out/share/icons/hicolor/256x256/apps"
      cp -r . "$appdir"

      install -Dm644 gui_data/img/GUI-Icon.png "$out/share/icons/hicolor/256x256/apps/ultimate-vocal-remover-gui.png"

      makeWrapper ${pythonEnv}/bin/python "$out/bin/ultimate-vocal-remover-gui" \
        --add-flags "\"\$UVR_DATA_HOME/UVR.py\"" \
        --prefix PATH : ${lib.makeBinPath [coreutils ffmpeg rubberband]} \
        --set TK_LIBRARY "${tk}/lib/${tk.libPrefix}" \
        --run 'export UVR_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/ultimate-vocal-remover-gui"' \
        --run 'mkdir -p "$UVR_DATA_HOME"' \
        --run 'UVR_APP_SRC=${placeholder "out"}/share/ultimate-vocal-remover-gui' \
        --run 'UVR_STAMP="$UVR_DATA_HOME/.nix-store-path"' \
        --run 'if ! test -f "$UVR_STAMP" || ! grep -qxF "$UVR_APP_SRC" "$UVR_STAMP"; then find "$UVR_DATA_HOME" -type d -exec chmod u+w {} + 2>/dev/null || true; cp -rT --remove-destination "$UVR_APP_SRC" "$UVR_DATA_HOME"; find "$UVR_DATA_HOME" -path "$UVR_DATA_HOME/models" -prune -o ! -type l -exec chmod u+w {} +; find "$UVR_DATA_HOME/models" -type d -exec chmod u+w {} +; printf "%s\n" "$UVR_APP_SRC" > "$UVR_STAMP"; fi' \
        --run 'ln -sfn ${ffmpeg}/bin/ffmpeg "$UVR_DATA_HOME/ffmpeg"' \
        --run 'ln -sfn ${rubberband}/bin/rubberband "$UVR_DATA_HOME/lib_v5/rubberband"' \
        --run 'cd "$UVR_DATA_HOME"'

      cat > "$out/share/applications/ultimate-vocal-remover-gui.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=Ultimate Vocal Remover
      Comment=Source separation GUI for removing vocals from audio files
      Exec=ultimate-vocal-remover-gui
      Icon=ultimate-vocal-remover-gui
      Categories=AudioVideo;Audio;
      Terminal=false
      EOF

      runHook postInstall
    '';

    meta = {
      description = "GUI for vocal removal and source separation using deep neural networks";
      homepage = "https://github.com/Anjok07/ultimatevocalremovergui";
      license = lib.licenses.mit;
      mainProgram = "ultimate-vocal-remover-gui";
      platforms = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    };
  }
