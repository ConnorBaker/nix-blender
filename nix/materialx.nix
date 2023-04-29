{
  cmake,
  ninja,
  libglvnd,
  openimageio,
  pkg-config,
  fetchFromGitHub,
  stdenv,
  xorg,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "materialx";
  version = "1.38.7";
  strictDepts = true;

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "MaterialX";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JovjGvcryjeczGwc1zEIf/HPzl2P+E125melspkTEMw=";
  };

  # The root CMakelists.txt sets CMAKE_CXX_STANDARD to 11, but we need 17.
  patchPhase = ''
    runHook prePatch
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_CXX_STANDARD 11)" "set(CMAKE_CXX_STANDARD 17)"
    runHook postPatch
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    openimageio
    libglvnd
    xorg.libX11
    xorg.libXt
  ];

  cmakeFlags = [
    "-DCMAKE_C_STANDARD=17"
    "-DCMAKE_CXX_STANDARD=17"

    "-DMATERIALX_BUILD_OIIO=ON"
    "-DMATERIALX_BUILD_TESTS=OFF"
    "-DMATERIALX_BUILD_SHARED_LIBS=ON"
    "-DMATERIALX_TEST_RENDER=OFF" # requires GPU
  ];
})
