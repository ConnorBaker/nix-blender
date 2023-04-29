{
  sphinx,
  buildPythonPackage,
  fetchFromGitHub,
}: let
  pname = "sphinx_press_theme";
  version = "0.8.0";
in
  buildPythonPackage {
    inherit pname version;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "schettino72";
      repo = pname;
      rev = version;
      hash = "sha256-BHfEZq9CffNeLOzKd1/G2lY90OiwlHSSVUue1YQHAbg=";
    };

    propagatedBuildInputs = [
      sphinx
    ];
  }
