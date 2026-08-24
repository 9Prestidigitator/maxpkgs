{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  bin2c,
  python3,
  callPackage,
  git,
  fetchurl,
}: let
  deps-file = callPackage ./nix_deps.nix {};
  eigen-dep = fetchurl {
    url = "https://gitlab.com/libeigen/eigen/-/archive/d10b27fe37736d2944630ecd7557cefa95cf87c9/eigen-d10b27fe37736d2944630ecd7557cefa95cf87c9.zip";
    sha256 = "sha256-74Y+0LIrELRqDrFfaqxRp9Bfu6EAqtgCSoZMkI7TAw4=";
  };
in
  stdenv.mkDerivation rec {
    pname = "libonnxruntime-neuralnote";
    version = "1ac0228d5d07890c0a504fbdeb6588e00afe1b8a";

    src = fetchFromGitHub {
      owner = "polygon";
      repo = "libonnxruntime-neuralnote";
      rev = "${version}";
      sha256 = "sha256-3u/iHDimvKgKY3yamFAi0HutWeqFHtjGRYUE7ljFpyQ=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      (python3.withPackages (ps:
        with ps; [
          flatbuffers
          onnxruntime
          onnx
        ]))
      git
      cmake
      bin2c
    ];

    dontConfigure = true;
    dontStrip = true;

    patchPhase = ''
      cp ${deps-file} onnxruntime/cmake/deps.txt
      sed -i -e 's#https://gitlab.com/libeigen/eigen/-/archive/d10b27fe37736d2944630ecd7557cefa95cf87c9/eigen-d10b27fe37736d2944630ecd7557cefa95cf87c9.zip#${eigen-dep}#' onnxruntime/cmake/external/eigen.cmake
      sed -i -e '/--parallel/a\' -e '--skip_submodule_sync \\' build-linux.sh build-mac.sh
      sed -i -e 's/CMAKE_OSX_ARCHITECTURES=/CMAKE_POLICY_VERSION_MINIMUM=3.5 CMAKE_OSX_ARCHITECTURES=/' build-linux.sh
      sed -i -e 's/--cmake_extra_defines CMAKE_OSX_ARCHITECTURES=/--cmake_extra_defines CMAKE_POLICY_VERSION_MINIMUM=3.5 CMAKE_OSX_ARCHITECTURES=/' build-mac.sh
      substituteInPlace build-mac.sh \
        --replace-fail 'build_arch "$onnx_config" x86_64' '# Build only the native Apple Silicon archive' \
        --replace-fail 'lipo -create onnxruntime-macOS_x86_64-static-combined.a onnxruntime-macOS_arm64-static-combined.a -output "lib/libonnxruntime.a"' 'cp onnxruntime-macOS_arm64-static-combined.a "lib/libonnxruntime.a"' \
        --replace-fail 'rm onnxruntime-macOS_x86_64-static-combined.a' ':'
    '';

    buildPhase =
      if stdenv.hostPlatform.isDarwin
      then ''
        sh convert-model-to-ort.sh model.onnx
        sh build-mac.sh model.required_operators_and_types.with_runtime_opt.config
        tar -czf libonnxruntime-neuralnote.tar.gz include lib model.with_runtime_opt.ort
      ''
      else ''
        sh convert-model-to-ort.sh model.onnx
        sh build-linux.sh
      '';

    installPhase = ''
      mkdir -p $out
      cp libonnxruntime-neuralnote.tar.gz $out/
    '';

    meta = {
      platforms = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    };
  }
