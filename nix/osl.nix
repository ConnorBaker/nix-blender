{
  bison,
  boost,
  cmake,
  fetchFromGitHub,
  flex,
  imath,
  llvmPackages, # llvm up through 15 including clang libraries
  ninja,
  openexr_3,
  openimageio,
  partio,
  pkg-config,
  pugixml,
  python3Packages, # pybind11, numpy
  stdenv,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "osl";
  version = "1.12.11.0";
  strictDeps = true;

  # outputs = ["bin" "dev" "out" "doc"];

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "OpenShadingLanguage";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kN0+dWOUPXK8+xtR7onuPNimdn8WcaKcSRkOnaoi7BQ=";
  };

  prePatch = ''
    for pcFile in $(find src/build-scripts/ -name '*.pc.in'); do
      substituteInPlace $pcFile --replace \
        'libdir=''${exec_prefix}/@CMAKE_INSTALL_LIBDIR@' \
        'libdir=@CMAKE_INSTALL_FULL_LIBDIR@'
    done
  '';

  nativeBuildInputs = [
    bison
    cmake
    flex
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    imath
    llvmPackages.clang
    llvmPackages.libclang
    llvmPackages.llvm.dev
    llvmPackages.llvm.out
    openexr_3
    openimageio
    partio
    pugixml
    python3Packages.numpy
    python3Packages.pybind11
    python3Packages.python
    zlib
  ];

  cmakeFlags = [
    "-DCMAKE_C_STANDARD=17"
    "-DCMAKE_CXX_STANDARD=17"
    "-DDOWNSTREAM_CXX_STANDARD=17"

    # Build system implies llvm-config and llvm-as are in the same directory.
    # Override defaults.
    "-DLLVM_DIRECTORY=${llvmPackages.llvm.out}"
    "-DLLVM_CONFIG=${llvmPackages.llvm.dev}/bin/llvm-config"
    "-DLLVM_BC_GENERATOR=${llvmPackages.clang}/bin/clang++"

    "-DOSL_BUILD_TESTS=OFF"
    "-DUSE_QT=OFF"
  ];
})
