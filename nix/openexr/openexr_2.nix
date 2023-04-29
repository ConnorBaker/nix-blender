{
  cmake,
  fetchFromGitHub,
  fetchpatch,
  lib,
  ninja,
  pkg-config,
  stdenv,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "openexr";
  version = "2.5.8";
  strictDeps = true;

  outputs = ["out" "lib" "include" "doc"];
  outputInclude = "include";

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-N7XdDaDsYdx4TXvHplQDTvhHNUmW5rntdaTKua4C0es=";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2021-45942.patch";
      url = "https://github.com/AcademySoftwareFoundation/openexr/commit/11cad77da87c4fa2aab7d58dd5339e254db7937e.patch";
      stripLen = 4;
      extraPrefix = "OpenEXR/IlmImf/";
      hash = "sha256-Xlur7P33lNPIlKQpU44H5q8w36KWzo0VvMMCpY2VQvE=";
    })
  ];

  # tests are determined to use /var/tmp on unix
  prePatch = ''
    for file in $(find . -name tmpDir.h); do
      substituteInPlace $file --replace '/var/tmp' "$TMPDIR"
    done
  '';

  cmakeFlags =
    [
      "-DCMAKE_C_STANDARD=17"
      "-DCMAKE_CXX_STANDARD=17"
      "-DPYILMBASE_ENABLE=OFF"
    ]
    ++ lib.optionals stdenv.hostPlatform.isStatic ["-DCMAKE_SKIP_RPATH=ON"];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [zlib];

  doCheck = true;

  meta = with lib; {
    description = "A high dynamic-range (HDR) image file format";
    homepage = "https://www.openexr.com/";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
})
