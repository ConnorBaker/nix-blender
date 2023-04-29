# ilmbase removed because no longer necessary given openexr_3
# cmakeFlags:
# "-DUSE_SIMD=arch=native"
# "-DCMAKE_C_STANDARD=17"
# "-DCMAKE_CXX_STANDARD=17"
# "-DDOWNSTREAM_CXX_STANDARD=17"
# Added:
# - libheif
# - libraw
# - libwebp
# - ninja
# - openjpeg
# - openvdb
# - pkg-config
# - ptex
# - tbb
# NOTE: FFMPEG and OpenCV and both massive dependencies that are not included by default.
{
  boost,
  cmake,
  fetchFromGitHub,
  fmt,
  giflib,
  lib,
  libheif,
  libjpeg,
  libpng,
  libraw,
  libtiff,
  libwebp,
  ninja,
  opencolorio,
  openexr_3,
  openjpeg,
  openvdb,
  pkg-config,
  ptex,
  robin-map,
  stdenv,
  tbb,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "openimageio";
  version = "2.4.10.0";
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "OpenImageIO";
    repo = "oiio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EQ9/G41AZJJ+KMIwDRZDf5V0VOx5fewmebeHlPWSPCQ=";
  };

  outputs = ["bin" "out" "dev" "doc"];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    unzip
  ];

  buildInputs = [
    boost
    giflib
    libheif
    libjpeg
    libpng
    libraw
    libtiff
    libwebp
    opencolorio
    openexr_3
    openjpeg
    openvdb
    ptex
    robin-map
    tbb
  ];

  propagatedBuildInputs = [fmt];

  cmakeFlags = [
    "-DCMAKE_C_STANDARD=17"
    "-DCMAKE_CXX_STANDARD=17"

    "-DDOWNSTREAM_CXX_STANDARD=17"
    "-DUSE_SIMD=arch=native"
    "-DUSE_PYTHON=OFF"
    "-DUSE_QT=OFF"
    # GNUInstallDirs
    "-DCMAKE_INSTALL_LIBDIR=lib" # needs relative path for pkg-config
    # Do not install a copy of fmt header files
    "-DINTERNALIZE_FMT=OFF"
  ];

  postFixup = ''
    substituteInPlace $dev/lib/cmake/OpenImageIO/OpenImageIOTargets-*.cmake \
      --replace "\''${_IMPORT_PREFIX}/lib/lib" "$out/lib/lib"
  '';

  meta = with lib; {
    homepage = "https://openimageio.org";
    description = "A library and tools for reading and writing images";
    license = licenses.bsd3;
    maintainers = with maintainers; [goibhniu];
    platforms = platforms.unix;
  };
})
