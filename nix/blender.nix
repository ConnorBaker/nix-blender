# TODO:
# - tile_size has artificial limit: intern/cycles/session/tile.h
#   - See `static const int MAX_TILE_SIZE = 8192;`
#  - Same file as above; tile writes to /tmp which can fill up
# - MaterialX: https://github.com/AcademySoftwareFoundation/MaterialX
# - USD: https://github.com/PixarAnimationStudios/USD ("-DWITH_USD=ON")
# - OpenColorIO: https://github.com/AcademySoftwareFoundation/OpenColorIO
# - OpenEXR3: Alread in Nixpkgs, but won't successfully compile.
{
  addOpenGLRunpath,
  blender-addons,
  boost,
  cmake,
  config,
  cudaPackages ? {},
  cudaSupport ? config.cudaSupport or false,
  eigen,
  fetchFromGitHub,
  fftw,
  freetype,
  gflags,
  glew-egl,
  glog,
  gmp,
  ilmbase,
  jemalloc,
  lib,
  libepoxy,
  materialx,
  libharu,
  libjpeg,
  libpng,
  libsamplerate,
  llvmPackages,
  libtiff,
  libwebp,
  lzo,
  makeWrapper,
  ninja,
  opencolorio,
  openexr,
  openimageio,
  openjpeg,
  opensubdiv,
  openvdb,
  optix-include,
  osl,
  pkg-config,
  potrace,
  pugixml,
  python310Packages,
  stdenv,
  tbb,
  zlib,
  usd,
  zstd,
}: let
  inherit
    (python310Packages)
    numpy
    python
    requests
    wrapPython
    ;
  cmakeCudaArchitectures = let
    inherit (builtins) concatStringsSep map;
    inherit (cudaPackages.cudaFlags) dropDot cudaCapabilities;
  in
    concatStringsSep ";" (map dropDot cudaCapabilities);

  cudaFlags = cudaPackages.cudaFlags.formatCapabilities {
    inherit (cudaPackages.cudaFlags) cudaCapabilities;
    enableForwardCompat = config.cudaForwardCompat;
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "blender";
    version = "3.6.0";

    src = fetchFromGitHub {
      owner = finalAttrs.pname;
      repo = finalAttrs.pname;
      rev = "d5757a0a100163d9490e9a8084f177faac67c39e";
      hash = "sha256-f7uairqB3cqrZTit8Oc3EdzfRYdqPzIG+GUOMei/miI=";
    };

    nativeBuildInputs = [
      addOpenGLRunpath
      # cudaPackages.autoAddOpenGLRunpathHook
      cmake
      makeWrapper
      ninja
      pkg-config
      wrapPython
    ];

    buildInputs =
      [
        blender-addons
        boost
        eigen
        fftw
        freetype
        gflags
        glew-egl
        glog
        gmp
        # ilmbase
        jemalloc
        libepoxy
        libharu
        libjpeg
        libpng
        libsamplerate
        libtiff
        libwebp
        llvmPackages.llvm
        lzo
        materialx
        opencolorio
        openexr
        openimageio
        openjpeg
        opensubdiv
        openvdb
        osl
        potrace
        pugixml
        python
        usd
        tbb
        zlib
        zstd
      ]
      ++ lib.optionals cudaSupport [
        cudaPackages.cuda_cudart
        cudaPackages.cuda_nvcc
        optix-include
      ];

    pythonPath = [
      numpy
      requests
    ];

    # TODO: Clean up logging via echo.
    # TODO: Check out
    #   https://github.com/NixOS/nixpkgs/blob/76a85de7a731a037f44f1fcc81165c934c66b0a2/pkgs/development/compilers/shaderc/default.nix#L40-L44
    #   They alternate between `cp -r --no-preserve=mode` and `ln -s.
    postUnpack = ''
      echo "Unpacking ${blender-addons}..."
      mkdir -p scripts/addons
      cp -r ${blender-addons}/* scripts/addons/
      echo "Unpacked!"
    '';

    prePatch =
      # Specify exactly which capabilities to build for
      ''
        substituteInPlace CMakeLists.txt --replace \
          'set(CYCLES_CUDA_BINARIES_ARCH sm_30 sm_35 sm_37 sm_50 sm_52 sm_60 sm_61 sm_70 sm_75 sm_86 compute_75 CACHE STRING "CUDA architectures to build binaries for")' \
          'set(CYCLES_CUDA_BINARIES_ARCH ${builtins.concatStringsSep " " cudaFlags.arches} CACHE STRING "CUDA architectures to build binaries for")'
      ''
      # Patches for Optix 7.7 and newer cudaPackages
      # See changelog: https://developer.download.nvidia.com/designworks/optix/secure/7.7/OptiX_Release_Notes_7.7_01.pdf?LFMKcBWuNP4fyjwyyZtqcTe8aRvBEVa48hTYxsRyxP8V3XiA_VqO8KC0Lc1_Vc-yHd7xcJZNud8l2R0uFsNu5VdWQTk97AsqzByx-GeX54Kcs9ZB6lVeie0R3TIAJPxV8JvmWp-_7Yk_Jj1LSFgQrUgwxMbD1Cqa7kQ=&t=eyJscyI6ImdzZW8iLCJsc2QiOiJodHRwczovL3d3dy5nb29nbGUuY29tLyJ9
      # TODO: Can be upstreamed
      + ''
        substituteInPlace intern/cycles/device/optix/device_impl.cpp --replace \
          'optixModuleCreateFromPTXWithTasks' \
          'optixModuleCreateWithTasks'

        substituteInPlace intern/cycles/device/optix/device_impl.cpp --replace \
          'optixModuleCreateFromPTX' \
          'optixModuleCreate'

        substituteInPlace intern/cycles/device/optix/device_impl.cpp --replace \
          'optixProgramGroupGetStackSize(groups[i], &stack_size[i])' \
          'optixProgramGroupGetStackSize(groups[i], &stack_size[i], NULL)'

        substituteInPlace intern/cycles/device/optix/device_impl.cpp --replace \
          'optixProgramGroupGetStackSize(osl_groups[i], &osl_stack_size[i])' \
          'optixProgramGroupGetStackSize(osl_groups[i], &osl_stack_size[i], NULL)'

        substituteInPlace intern/cycles/device/optix/device_impl.cpp --replace \
          'link_options.debugLevel = module_options.debugLevel;' \
          ""

        substituteInPlace intern/cycles/device/optix/device_impl.cpp --replace \
          'link_options.debugLevel = OPTIX_COMPILE_DEBUG_LEVEL_NONE;' \
          ""
      '';

    cmakeFlags =
      [
        "-DCMAKE_C_STANDARD=17"
        "-DCMAKE_CXX_STANDARD=17"

        "-DPYTHON_INCLUDE_DIR=${python}/include/${python.libPrefix}"
        "-DPYTHON_LIBPATH=${python}/lib"
        "-DPYTHON_LIBRARY=${python.libPrefix}"
        "-DPYTHON_NUMPY_INCLUDE_DIRS=${numpy}/${python.sitePackages}/numpy/core/include"
        "-DPYTHON_NUMPY_PATH=${numpy}/${python.sitePackages}"
        "-DPYTHON_VERSION=${python.pythonVersion}"
        "-DWITH_ALEMBIC=OFF"
        "-DWITH_AUDASPACE=OFF"
        "-DWITH_BUILDINFO=OFF"
        "-DWITH_CODEC_AVI=OFF"
        "-DWITH_CODEC_FFMPEG=OFF"
        "-DWITH_CODEC_SNDFILE=OFF"
        "-DWITH_CYCLES_EMBREE=OFF"
        "-DWITH_CYCLES_NATIVE_ONLY=ON"
        "-DWITH_CYCLES_OSL=ON"
        "-DWITH_CYCLES_PATH_GUIDING=OFF" # Currently CPU-only, using Intel's OpenPGL
        "-DWITH_DRACO=OFF"
        "-DWITH_HEADLESS=ON"
        "-DWITH_INPUT_NDOF=OFF"
        "-DWITH_INSTALL_PORTABLE=OFF"
        "-DWITH_LIBS_PRECOMPILED=OFF"
        "-DWITH_OPENCOLLADA=OFF"
        "-DWITH_OPENIMAGEDENOISE=OFF"
        "-DWITH_PYTHON_INSTALL_NUMPY=OFF"
        "-DWITH_PYTHON_INSTALL_REQUESTS=OFF"
        "-DWITH_PYTHON_INSTALL=OFF"
        "-DWITH_SDL=OFF"
        "-DWITH_SYSTEM_EIGEN3=ON"
        "-DWITH_SYSTEM_FREETYPE=ON"
        "-DWITH_SYSTEM_GFLAGS=ON"
        "-DWITH_SYSTEM_GLOG=ON"
        "-DWITH_SYSTEM_LZO=ON"
        "-DWITH_USD=ON"
        "-DUSD_LIBRARY=${usd}"
        "-DWITH_MATERIALX=ON"
        "-DWITH_LLVM=ON"
        "-DWITH_OPENMP=OFF"
      ]
      ++ lib.optionals cudaSupport [
        "-DCMAKE_CUDA_ARCHITECTURES=${cmakeCudaArchitectures}"
        "-DOPTIX_ROOT_DIR=${optix-include}"
        "-DWITH_CYCLES_CUDA_BINARIES=ON"
        "-DWITH_CYCLES_DEVICE_OPTIX=ON"
      ];

    env.NIX_CFLAGS_COMPILE = "-I${ilmbase.dev}/include/OpenEXR -I${python}/include/${python.libPrefix}";
    # env.NIX_CFLAGS_COMPILE = "-I${python}/include/${python.libPrefix}";

    postInstall = ''
      buildPythonPath "$pythonPath"
      wrapProgram $out/bin/blender \
        --prefix PATH : $program_PATH \
        --prefix PYTHONPATH : "$program_PYTHONPATH" \
        --add-flags '--python-use-system-env'
    '';

    # Set RUNPATH so that libcuda and libnvrtc in /run/opengl-driver(-32)/lib can be
    # found. See the explanation in libglvnd.
    postFixup = lib.optionalString cudaSupport ''
      for program in $out/bin/blender $out/bin/.blender-wrapped; do
        isELF "$program" || continue
        addOpenGLRunpath "$program"
      done
    '';

    meta = with lib; {
      description = "3D Creation/Animation/Publishing System";
      homepage = "https://www.blender.org";
      # They comment two licenses: GPLv2 and Blender License, but they
      # say: "We've decided to cancel the BL offering for an indefinite period."
      # OptiX, enabled with cudaSupport, is non-free.
      license = with licenses; [gpl2Plus] ++ optional cudaSupport unfree;
      platforms = ["x86_64-linux" "aarch64-linux"];
      maintainers = with maintainers; [goibhniu veprbl];
    };
  })
