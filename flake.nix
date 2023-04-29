{
  inputs = {
    nixGL = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  nixConfig.bash-prompt = "🐚 ";

  outputs = {
    self,
    nixGL,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    nvidiaDriver = {
      version = "530.41.03";
      sha256 = "sha256-riehapaMhVA/XRYd2jQ8FgJhKwJfSu4V+S4uoKy3hLE=";
    };
    pkgs = let
      cudaEnabledPkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
          cudaCapabilities = ["8.9"];
          cudaForwardCompat = false;
        };
        overlays = [
          (_: prev: {
            cudaPackages = prev.cudaPackages_12;
            llvmPackages = prev.llvmPackages_15;
            python3Packages = prev.python310Packages;
          })
          nixGL.overlays.default
        ];
      };
    in
      cudaEnabledPkgs.extend (_: prev:
        (import ./nix/openexr {inherit (prev) callPackage;})
        // {
          sphinx-press-theme = prev.python3Packages.callPackage ./nix/sphinx-press-theme.nix {};
          blender = prev.callPackage ./nix/blender.nix {};
          blender-addons = prev.callPackage ./nix/blender-addons.nix {};
          imath = prev.callPackage ./nix/imath.nix {};
          materialx = prev.callPackage ./nix/materialx.nix {};
          opencolorio = prev.callPackage ./nix/opencolorio.nix {};
          openimageio = prev.callPackage ./nix/openimageio.nix {};
          opensubdiv = prev.callPackage ./nix/opensubdiv.nix {};
          openvdb = prev.callPackage ./nix/openvdb.nix {};
          optix-include = prev.callPackage ./nix/optix-include.nix {};
          osl = prev.callPackage ./nix/osl.nix {};
          usd = prev.callPackage ./nix/usd.nix {};
        });

    inherit (pkgs.nixgl.nvidiaPackages nvidiaDriver) nixGLNvidia;
  in {
    packages.${system} = {
      inherit
        (pkgs)
        blender
        blender-addons
        imath
        materialx
        opencolorio
        openexr
        openexr_2
        openexr_3
        openimageio
        opensubdiv
        openvdb
        optix-include
        osl
        sphinx-press-theme
        usd
        ;
      default = self.packages.${system}.blender;
      runner = pkgs.callPackage ./blender-headless-runner {
        inherit nixGLNvidia;
        inherit (self.packages.${system}) blender;
        blenderConfig = {
          preferences.addons.cycles.preferences = {
            compute_device_type = "OPTIX";
            kernel_optimization_level = "FULL";
          };
          scene = {
            render = {
              filepath = "//render";
              use_file_extension = true;
              resolution_percentage = 1600;
              image_settings = {
                file_format = "PNG";
                # file_format = "JPEG2000";
                # compression = 100;
                # quality = 100;
              };
            };
            cycles = {
              device = "GPU";
              use_denoising = false;
              denoiser = "OPTIX";
              samples = 32;
              use_auto_tile = true;
              tile_size = 8192;
            };
          };
        };
      };
    };
    formatter.${system} = pkgs.alejandra;
  };
}
