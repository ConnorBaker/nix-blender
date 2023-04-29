{
  boost,
  cmake,
  fetchFromGitHub,
  fetchpatch,
  jemalloc,
  lib,
  ninja,
  opensubdiv,
  pkg-config,
  stdenv,
  tbb,
  xorg,
  # MaterialX support
  materialxSupport ? false,
  materialx,
  # OpenColorIO support
  buildOpenColorIOPlugin ? true,
  opencolorio,
  # OpenImageIO support
  buildOpenImageIOPlugin ? true,
  openimageio,
  # OpenGL support
  glSupport ? true,
  libglvnd,
  # OSL support
  oslSupport ? true,
  osl,
  # Python support
  pythonSupport ? false,
  python3Packages,
  # PTex support
  ptexSupport ? true,
  ptex,
  # Vulkan support
  vulkanSupport ? false,
  # OpenVDB support
  openvdbSupport ? true,
  openvdb,
}: let
  inherit (lib) lists;
  setBool = b:
    if b
    then "ON"
    else "OFF";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "usd";
    version = "23.05";
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "PixarAnimationStudios";
      repo = "USD";
      rev = "v${finalAttrs.version}";
      hash = "sha256-3wM6stJnpznTU7Lb0vAdeO0/cr8n9rhvPZgT7PGAe04=";
    };

    patches = [
      (fetchpatch {
        name = "drawModeStandin.cpp-missing-include-array.patch";
        url = "https://github.com/PixarAnimationStudios/USD/pull/2410.patch";
        hash = "sha256-WDLUqK6/gKHv7kj2ipHfav/Z64uAXQGr8152vRHj3b8=";
      })
    ];

    # cmake/defaults/CXXDefaults.cmake hardcodes the CMAKE_CXX_STANDARD to 14. We change it to 17.
    prePatch = ''
      substituteInPlace cmake/defaults/CXXDefaults.cmake \
        --replace "set(CMAKE_CXX_STANDARD 14)" "set(CMAKE_CXX_STANDARD 17)"
    '';

    # TODO: Not sure how to refactor this to work. Missing template arguments.
    # substituteInPlace pxr/usdImaging/bin/usdBakeMtlx/bakeMaterialX.cpp --replace \
    #     "mx::TextureBakerPtr baker = mx::TextureBaker::create" \
    #     "auto baker = mx::TextureBaker<mx::GlslRenderer, mx::GlslShaderGenerator>::create"

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
    ];

    buildInputs =
      [
        boost
        opensubdiv
        tbb
        xorg.libX11
      ]
      ++ lists.optionals glSupport [libglvnd]
      # TODO: Python support is non-functional because pyside6 and shiboken6 are not packaged.
      ++ lists.optionals pythonSupport [
        # Python component of boost is required for USD.
        python3Packages.boost
        python3Packages.jinja2
        python3Packages.pyside6
        python3Packages.python
      ]
      ++ lists.optionals buildOpenColorIOPlugin [opencolorio]
      ++ lists.optionals buildOpenImageIOPlugin [openimageio]
      ++ lists.optionals materialxSupport [materialx]
      ++ lists.optionals openvdbSupport [openvdb]
      ++ lists.optionals oslSupport [osl]
      ++ lists.optionals ptexSupport [ptex];

    cmakeFlags = [
      "-DCMAKE_C_STANDARD=17"
      "-DCMAKE_CXX_STANDARD=17"

      # https://github.com/PixarAnimationStudios/USD/blob/b53573ea2a6b29bc4a6b129f604bbb342c35df5c/cmake/defaults/Packages.cmake#L166
      "-DPXR_MALLOC_LIBRARY=${jemalloc}/lib/libjemalloc.so"

      # https://github.com/PixarAnimationStudios/USD/blob/b53573ea2a6b29bc4a6b129f604bbb342c35df5c/cmake/defaults/Options.cmake
      "-DPXR_BUILD_ALEMBIC_PLUGIN=OFF"
      "-DPXR_BUILD_DOCUMENTATION=OFF"
      "-DPXR_BUILD_DRACO_PLUGIN=OFF"
      "-DPXR_BUILD_EMBREE_PLUGIN=OFF"
      "-DPXR_BUILD_EXAMPLES=OFF"
      "-DPXR_BUILD_IMAGING=ON"
      "-DPXR_BUILD_OPENCOLORIO_PLUGIN=${setBool buildOpenColorIOPlugin}"
      "-DPXR_BUILD_OPENIMAGEIO_PLUGIN=${setBool buildOpenImageIOPlugin}"
      # "-DPXR_BUILD_PRMAN_PLUGIN=OFF"
      "-DPXR_BUILD_PYTHON_DOCUMENTATION=OFF"
      "-DPXR_BUILD_TESTS=OFF"
      "-DPXR_BUILD_TUTORIALS=OFF"
      "-DPXR_BUILD_USD_IMAGING=ON"
      "-DPXR_BUILD_USD_TOOLS=ON"
      # "-DPXR_BUILD_USDVIEW=ON"
      "-DPXR_BUILD_USDVIEW=OFF" # Requires pyside6 and pyopengl

      "-DPXR_ENABLE_GL_SUPPORT=${setBool glSupport}"
      "-DPXR_ENABLE_HDF5_SUPPORT=OFF"
      "-DPXR_ENABLE_MATERIALX_SUPPORT=${setBool materialxSupport}"
      "-DPXR_ENABLE_METAL_SUPPORT=ON"
      "-DPXR_ENABLE_NAMESPACES=ON"
      "-DPXR_ENABLE_OPENVDB_SUPPORT=${setBool openvdbSupport}"
      "-DPXR_ENABLE_OSL_SUPPORT=${setBool oslSupport}"
      "-DPXR_ENABLE_PTEX_SUPPORT=${setBool ptexSupport}"
      "-DPXR_ENABLE_PYTHON_SUPPORT=${setBool pythonSupport}"
      "-DPXR_ENABLE_VULKAN_SUPPORT=${setBool vulkanSupport}"

      "-DPXR_HEADLESS_TEST_MODE=ON"
      "-DPXR_PREFER_SAFETY_OVER_SPEED=ON"
      "-DPXR_STRICT_BUILD_MODE=OFF"
      "-DPXR_USE_DEBUG_PYTHON=OFF"
      "-DPXR_VALIDATE_GENERATED_CODE=OFF"
    ];
  })
