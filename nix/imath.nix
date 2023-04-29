{
  cmake,
  fetchFromGitHub,
  lib,
  ninja,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "imath";
  version = "3.1.7";
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-8TkrRqQYnp9Ho8jT22EQCEBIjlRWYlOAZSNOnJ5zCM0=";
  };

  doCheck = true;

  outputs = ["out" "lib" "include"];
  outputInclude = "include";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  cmakeFlags = [
    "-DCMAKE_C_STANDARD=17"
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "Imath is a C++ and python library of 2D and 3D vector, matrix, and math operations for computer graphics";
    homepage = "https://github.com/AcademySoftwareFoundation/Imath";
    license = licenses.bsd3;
    maintainers = with maintainers; [paperdigits];
    platforms = platforms.all;
  };
})
