{
  boost,
  c-blosc,
  cmake,
  fetchFromGitHub,
  imath,
  jemalloc,
  lib,
  gtest,
  doxygen,
  texlive,
  cudaPackages,
  ninja,
  openexr_3,
  pkg-config,
  stdenv,
  tbb,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "openvdb";
  version = "10.0.1";
  strictDeps = true;

  # TODO: We also have a static output to take care of
  outputs = ["out" "lib" "include" "doc"];
  outputInclude = "include";

  doCheck = true;

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-kaf5gpGYVWinmnRwR/IafE1SJcwmP2psfe/UZdtH1Og=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    cudaPackages.cuda_nvcc
    doxygen
    texlive.combined.scheme-small
  ];

  checkInputs = [
    gtest
  ];

  buildInputs = [
    boost
    c-blosc
    jemalloc
    openexr_3
    tbb
    cudaPackages.cuda_cudart
  ];

  propagatedBuildInputs = [
    imath
  ];

  cmakeFlags = [
    "-DCMAKE_C_STANDARD=17"
    "-DCMAKE_CXX_STANDARD=17"

    "-DCONCURRENT_MALLOC=Jemalloc"
    "-DOPENVDB_ENABLE_UNINSTALL=OFF"
    "-DOPENVDB_SIMD=AVX"
    "-DUSE_EXR=ON"
    "-DUSE_IMATH_HALF=ON"
    "-DUSE_NANOVDB=ON"

  "-DOPENVDB_BUILD_UNITTESTS=ON"
  "-DOPENVDB_BUILD_NANOVDB=ON"
  "-DNANOVDB_BUILD_TOOLS=ON"
  "-DNANOVDB_BUILD_UNITTESTS=ON"
  "-DOPENVDB_BUILD_DOCS=ON"

    "-DNANOVDB_USE_INTRINSICS=ON"
    "-DNANOVDB_USE_CUDA=ON"
    "-DNANOVDB_CUDA_KEEP_PTX=ON"
    "-DNANOVDB_USE_OPENVDB=ON"
  ];

  # TODO: Is this neccessary?
  # postFixup = ''
  #   substituteInPlace $dev/lib/cmake/OpenVDB/FindOpenVDB.cmake \
  #     --replace \''${OPENVDB_LIBRARYDIR} $out/lib \
  #     --replace \''${OPENVDB_INCLUDEDIR} $dev/include
  # '';

  meta = with lib; {
    description = "Sparse volume data structure and tools";
    homepage = "https://www.openvdb.org";
    maintainers = [maintainers.guibou];
    platforms = platforms.unix;
    license = licenses.mpl20;
  };
})
