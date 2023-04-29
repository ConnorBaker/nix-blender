{callPackage}: let
  openexr_2 = callPackage ./openexr_2.nix {};
  openexr_3 = callPackage ./openexr_3.nix {};
in {
  inherit openexr_2 openexr_3;
  openexr = openexr_2;
}
