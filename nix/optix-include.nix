{
  fetchzip,
  lib,
  stdenv,
}:
stdenv.mkDerivation (final: {
  pname = "optix-include";
  version = "7.7.0";
  strictDeps = true;

  src = let
    majorMinor = lib.versions.majorMinor final.version;
  in
    fetchzip {
      # url taken from the archlinux blender PKGBUILD
      url = "https://developer.download.nvidia.com/redist/optix/v${majorMinor}/OptiX-${majorMinor}-Include.zip";
      hash = "sha256-tDBJAI2CeqbqEsV1rH5ozeHjfmZQh7Fk4hmCFmZtqx8=";
      stripRoot = false;
    };

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    cp -r $src $out
    runHook postInstall
  '';
})
