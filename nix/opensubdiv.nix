{
  cmake,
  config,
  cudaPackages ? {},
  cudaSupport ? config.cudaSupport or false,
  darwin,
  fetchFromGitHub,
  headlessSupport ? true,
  lib,
  libglvnd,
  llvmPackages,
  ninja,
  ocl-icd,
  openclSupport ? false,
  openmpSupport ? false,
  pkg-config,
  ptex,
  python3,
  stdenv,
  tbb,
  tbbSupport ? true,
  zlib,
}: let
  cudaArchitectures = let
    inherit (builtins) concatStringsSep map;
    inherit (cudaPackages.cudaFlags) dropDot cudaCapabilities;
  in
    concatStringsSep ";" (map dropDot cudaCapabilities);
in
  stdenv.mkDerivation {
    pname = "opensubdiv";
    version = "3.5.0";
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "PixarAnimationStudios";
      repo = "OpenSubdiv";
      rev = "v3_5_0";
      sha256 = "sha256-pYD2HxAszE9Ux1xsSJ7s2R13U8ct5tDo3ZP7H0+F9Rc=";
    };

    outputs = ["out" "dev"];

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
    ];
    buildInputs =
      [
        ptex
        libglvnd
        python3
        tbb
        zlib
      ]
      ++ lib.optionals tbbSupport [
        tbb
      ]
      ++ lib.optionals openmpSupport [llvmPackages.openmp]
      ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [OpenCL Cocoa CoreVideo IOKit AppKit AGL])
      ++ lib.optionals openclSupport [
        ocl-icd
      ]
      ++ lib.optionals cudaSupport (with cudaPackages; [
        cuda_cudart
        cuda_nvcc
      ]);

    cmakeFlags =
      [
        "-DCMAKE_C_STANDARD=17"
        "-DCMAKE_CXX_STANDARD=17"

        "-DNO_EXAMPLES=ON"
        "-DNO_TUTORIALS=ON"
        "-DNO_REGRESSION=OFF"
        "-DNO_DOC=ON"

        # DirectX is windows-only
        "-DNO_DX=1"
      ]
      ++ lib.optionals tbbSupport [
        "-DNO_TBB=OFF"
        "-DNO_OMP=ON"
      ]
      ++ lib.optionals openmpSupport [
        "-DNO_TBB=ON"
        "-DNO_OMP=OFF"
      ]
      ++ lib.optionals stdenv.isDarwin [
        "-DNO_METAL=OFF"
        "-DNO_MACOS_FRAMEWORK=OFF"
        "-DNO_GLFW_X11=ON"
        "-DNO_GLFW=ON"
      ]
      ++ lib.optionals headlessSupport [
        "-DNO_GLFW_X11=ON"
      ]
      ++ lib.optionals openclSupport [
        "-DNO_CLEW=OFF"
        "-DNO_OPENCL=OFF"
        "-DNO_CUDA=ON"
      ]
      ++ lib.optionals cudaSupport [
        "-DNO_CUDA=OFF"
        "-DNO_OPENCL=ON"

        # Pass the cuda architectures to CMake.
        "-DCMAKE_CUDA_ARCHITECTURES=${cudaArchitectures}"
        # If we do not set this flag, OSD adds ancient CUDA flags that are not supported by the
        # current CUDA version.
        "-DOSD_CUDA_NVCC_FLAGS="
      ];

    postInstall = "rm $out/lib/*.a";

    meta = {
      description = "An Open-Source subdivision surface library";
      homepage = "http://graphics.pixar.com/opensubdiv";
      platforms = lib.platforms.unix;
      maintainers = [lib.maintainers.eelco];
      license = lib.licenses.asl20;
    };
  }
