{
  cmake,
  expat,
  fetchFromGitHub,
  imath,
  lib,
  minizip-ng,
  ninja,
  pkg-config,
  pkgs,
  pystring,
  stdenv,
  yaml-cpp,
  # Only required on Linux
  freeglut,
  glew,
  # Only required/available on Darwin, lazily accessed via pkgs
  Carbon ? pkgs.Carbon,
  Cocoa ? pkgs.Cocoa,
  GLUT ? pkgs.GLUT,
  # Python bindings
  pythonBindings ? true, # Python bindings
  python3Packages,
  # Build apps
  buildApps ? true, # Utility applications
  lcms2,
  openexr_3,
}: let
  setBool = b:
    if b
    then "ON"
    else "OFF";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "opencolorio";
    version = "2.2.1";
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "AcademySoftwareFoundation";
      repo = "OpenColorIO";
      rev = "v${finalAttrs.version}";
      hash = "sha256-9Og8EyhtGc3EDbdKB8QMGMEUDPz9/VjmAGMl5sEuJ5k=";
    };

    outputs = ["out" "lib" "include"];
    outputInclude = "include";

    # patches = [
    #   (fetchpatch {
    #     name = "darwin-no-hidden-l.patch";
    #     url = "https://github.com/AcademySoftwareFoundation/OpenColorIO/commit/48bab7c643ed8d108524d718e5038d836f906682.patch";
    #     revert = true;
    #     sha256 = "sha256-0DF+lwi2nfkUFG0wYvL3HYbhZS6SqGtPWoOabrFS1Eo=";
    #   })
    # ];

    prePatch =
      # these tests don't like being run headless on darwin. no builtin
      # way of skipping tests so this is what we're reduced to.
      lib.optionalString stdenv.isDarwin ''
        substituteInPlace tests/cpu/Config_tests.cpp \
          --replace 'OCIO_ADD_TEST(Config, virtual_display)' 'static void _skip_virtual_display()' \
          --replace 'OCIO_ADD_TEST(Config, virtual_display_with_active_displays)' 'static void _skip_virtual_display_with_active_displays()'
      '';

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
    ];
    buildInputs =
      [
        expat
        imath
        minizip-ng
        pystring
        yaml-cpp
      ]
      ++ lib.optionals buildApps [lcms2 openexr_3]
      ++ lib.optionals pythonBindings [python3Packages.python python3Packages.pybind11]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [Carbon GLUT Cocoa]
      ++ lib.optionals stdenv.hostPlatform.isLinux [glew freeglut];

    cmakeFlags = [
      "-DCMAKE_C_STANDARD=17"
      "-DCMAKE_CXX_STANDARD=17"

      "-DOCIO_INSTALL_EXT_PACKAGES=NONE"
      # GPU test fails with: freeglut (GPU tests): failed to open display ''
      "-DOCIO_BUILD_GPU_TESTS=OFF"

      "-DOCIO_BUILD_APPS=${setBool buildApps}"
      "-DOCIO_BUILD_PYTHON=${setBool pythonBindings}"
    ];

    # precision issues on non-x86
    doCheck = stdenv.isx86_64;

    meta = with lib; {
      homepage = "https://opencolorio.org";
      description = "A color management framework for visual effects and animation";
      license = licenses.bsd3;
      maintainers = [maintainers.rytone];
      platforms = platforms.unix;
    };
  })
