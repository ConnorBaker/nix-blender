{
  fetchFromGitHub,
  lib,
  stdenv,
}:
stdenv.mkDerivation (final: {
  pname = "blender-addons";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "blender";
    repo = final.pname;
    rev = "bedf2014dbee52806e66131d626ea90ce09f154b";
    hash = "sha256-BI9+zyM8z7FWBfBxUJehpJmcTAD46CtM5ejvLpyssus=";
  };

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    cp -r $src $out
    runHook postInstall
  '';

  meta = {
    description = "Add-ons bundled with Blender releases";
    homepage = "https://www.blender.org";
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    maintainers = with lib.maintainers; [connorbaker];
  };
})
