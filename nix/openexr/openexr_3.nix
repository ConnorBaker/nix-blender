{
  cmake,
  doxygen,
  fetchFromGitHub,
  sphinx-press-theme,
  python3Packages,
  graphviz,
  imath,
  lib,
  ninja,
  pkg-config,
  stdenv,
  sphinx,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "openexr";
  version = "3.1.7";
  strictDeps = true;

  outputs = ["out" "lib" "include" "doc"];
  outputInclude = "include";

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-Kl+aOA797aZvrvW4ZQNHdSU7YFPieZEzX3aYeaoH6eU=";
  };

  # tests are determined to use /var/tmp on unix
  prePatch = ''
    cat <(find . -name tmpDir.h) <(echo src/test/OpenEXRCoreTest/main.cpp) | while read -r f ; do
      substituteInPlace $f --replace '/var/tmp' "$TMPDIR"
    done
  '';

  cmakeFlags =
    [
      "-DCMAKE_C_STANDARD=17"
      "-DCMAKE_CXX_STANDARD=17"
      "-DBUILD_DOCS=ON"
      "-DOPENEXR_INSTALL_EXAMPLES=OFF"
    ]
    ++ lib.optionals stdenv.hostPlatform.isStatic ["-DCMAKE_SKIP_RPATH=ON"];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    sphinx
    sphinx-press-theme
    python3Packages.breathe
    doxygen
    graphviz
  ];
  buildInputs = [
    imath
  ];
  propagatedBuildInputs = [zlib];

  # Without 'sse' enforcement tests fail on i686 as due to excessive precision as:
  #   error reading back channel B pixel 21,-76 got -nan expected -nan
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isi686 "-msse2 -mfpmath=sse";

  doCheck = true;

  meta = with lib; {
    description = "A high dynamic-range (HDR) image file format";
    homepage = "https://www.openexr.com";
    license = licenses.bsd3;
    maintainers = with maintainers; [paperdigits];
    platforms = platforms.all;
  };
})
