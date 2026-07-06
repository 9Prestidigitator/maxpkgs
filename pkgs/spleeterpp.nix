{
  cmake,
  eigen,
  fetchFromGitHub,
  fetchurl,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "spleeterpp";
  version = "0.2.1-unstable-2026-06-16";

  src = fetchFromGitHub {
    owner = "gvne";
    repo = "spleeterpp";
    rev = "cbc6136959dc3ccf3a06bfc5e4b5f0fa1591b822";
    hash = "sha256-tPXsQaxSn5GP5I2fDzLhYNXFUhDedsAzNL7wgjGDhUY=";
  };

  tensorflow = fetchurl {
    url = "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz";
    hash = "sha256-3sv9WnCeztNSP1XM+iOTN6h+GrPgAO/aNhfbeeEDTe0=";
  };

  offlineModels = fetchurl {
    url = "https://github.com/gvne/spleeterpp/releases/download/models-1.0/models.zip";
    hash = "sha256-7f29ubgwaY/IWa+7nx5diyp9oewz7RzMKI6aV+8MTKI=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    eigen
  ];

  postUnpack = ''
    mkdir -p "$NIX_BUILD_TOP/tensorflow"
    tar -xzf ${finalAttrs.tensorflow} -C "$NIX_BUILD_TOP/tensorflow"
  '';

  postPatch = ''
    cat > cmake/add_eigen.cmake <<'EOF'
    find_package(Eigen3 REQUIRED NO_MODULE)
    EOF

    cat > cmake/add_tensorflow.cmake <<EOF
    set(tensorflow_dir "$NIX_BUILD_TOP/tensorflow")

    find_library(tensorflow_lib
      NAMES tensorflow
      PATHS "\''${tensorflow_dir}/lib"
      REQUIRED
      NO_DEFAULT_PATH
    )
    find_library(tensorflow_framework_lib
      NAMES tensorflow_framework
      PATHS "\''${tensorflow_dir}/lib"
      REQUIRED
      NO_DEFAULT_PATH
    )

    add_library(tensorflow INTERFACE)
    target_link_libraries(tensorflow
      INTERFACE "\''${tensorflow_lib}" "\''${tensorflow_framework_lib}"
    )
    target_include_directories(tensorflow
      INTERFACE "\''${tensorflow_dir}/include"
    )

    install(FILES
      "\''${tensorflow_dir}/lib/libtensorflow.so.1.15.0"
      "\''${tensorflow_dir}/lib/libtensorflow_framework.so.1.15.0"
      DESTINATION lib
    )
    install(DIRECTORY "\''${tensorflow_dir}/include/tensorflow" DESTINATION include)
    install(CODE "execute_process(COMMAND \''${CMAKE_COMMAND} -E create_symlink libtensorflow.so.1.15.0 \''${CMAKE_INSTALL_PREFIX}/lib/libtensorflow.so.1)")
    install(CODE "execute_process(COMMAND \''${CMAKE_COMMAND} -E create_symlink libtensorflow.so.1 \''${CMAKE_INSTALL_PREFIX}/lib/libtensorflow.so)")
    install(CODE "execute_process(COMMAND \''${CMAKE_COMMAND} -E create_symlink libtensorflow_framework.so.1.15.0 \''${CMAKE_INSTALL_PREFIX}/lib/libtensorflow_framework.so.1)")
    install(CODE "execute_process(COMMAND \''${CMAKE_COMMAND} -E create_symlink libtensorflow_framework.so.1 \''${CMAKE_INSTALL_PREFIX}/lib/libtensorflow_framework.so)")
    EOF

    cat > cmake/add_spleeter_models.cmake <<EOF
    set(spleeter_env_dir "\''${CMAKE_CURRENT_BINARY_DIR}/models")
    set(spleeter_models_dir "\''${spleeter_env_dir}/offline")
    file(MAKE_DIRECTORY "\''${spleeter_models_dir}")
    execute_process(
      COMMAND "\''${CMAKE_COMMAND}" -E tar -xf "${finalAttrs.offlineModels}"
      WORKING_DIRECTORY "\''${spleeter_models_dir}"
      COMMAND_ERROR_IS_FATAL ANY
    )
    EOF
  '';

  cmakeFlags = [
    "-Dspleeter_enable_filter=OFF"
    "-Dspleeter_enable_tests=OFF"
  ];

  meta = {
    description = "C++ inference library for Spleeter source separation";
    homepage = "https://github.com/gvne/spleeterpp";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
  };
})
