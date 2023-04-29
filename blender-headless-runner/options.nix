# NOTE: Use snake_case for all keys and values because they are passed directly to the Python API.
{lib, ...}: let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in {
  options = {
    preferences.addons.cycles.preferences = {
      compute_device_type = mkOption {
        type = types.nullOr (types.enum ["NONE" "CUDA" "OPTIX" "HIP" "METAL" "ONEAPI"]);
        default = null;
        description = ''
          Compute Device Type

          Device to use for computation (rendering with Cycles).

          NONE: Don't use compute device.
          CUDA: Use CUDA for GPU acceleration.
          OPTIX: Use OptiX for GPU acceleration.
          HIP: Use HIP for GPU acceleration.
          METAL: Use Metal for GPU acceleration.
          ONEAPI: Use oneAPI for GPU acceleration.
        '';
      };
      peer_memory = mkOption {
        type = types.nullOr (types.bool);
        default = null;
        description = ''
          Distribute memory across devices

          Make more room for large scenes to fit by distributing memory across interconnected
          devices (e.g. via NVLink) rather than duplicating it.
        '';
      };
      use_metalrt = mkOption {
        type = types.nullOr (types.bool);
        default = null;
        description = ''
          MetalRT (Experimental)

          MetalRT for ray tracing uses less memory for scenes which use curves extensively, and
          can give better performance in specific cases. However this support is experimental and
          some scenes may render incorrect.
        '';
      };
      use_oneapirt = mkOption {
        type = types.nullOr (types.bool);
        default = null;
        description = ''
          Embree on GPU (Experimental)

          Embree GPU execution will allow to use hardware ray tracing on Intel GPUs, which will
          provide better performance. However this support is experimental and some scenes may
          render incorrectly.
        '';
      };
      kernel_optimization_level = mkOption {
        type = types.nullOr (types.enum ["OFF" "INTERSECT" "FULL"]);
        default = null;
        description = ''
          Kernel Optimization

          Kernels can be optimized based on scene content. Optimized kernels are requested at the
          start of a render. If optimized kernels are not available, rendering will proceed using
          generic kernels until the optimized set is available in the cache. This can result in
          additional CPU usage for a brief time (tens of seconds).

          OFF: Disable kernel optimization. Slowest rendering, no extra background CPU usage.
          INTERSECT: Optimize only intersection kernels. Faster rendering, negligible extra
            background CPU usage.
          FULL: Optimize all kernels. Fastest rendering, may result in extra background CPU usage.
        '';
      };
    };
    scene = {
      frame_start = mkOption {
        type = types.nullOr (types.ints.between 0 1048574);
        default = null;
        description = ''
          First frame of the playback/rendering range.
        '';
      };
      frame_step = mkOption {
        type = types.nullOr (types.ints.between 0 1048574);
        default = null;
        description = ''
          Number of frames to skip forward while rendering/playing back each frame.
        '';
      };
      frame_end = mkOption {
        type = types.nullOr (types.ints.between 0 1048574);
        default = null;
        description = ''
          Final frame of the playback/rendering range.
        '';
      };
      render = {
        filepath = mkOption {
          type = types.nullOr (types.str);
          default = null;
          description = ''
            Directory/name to save animations, # characters defines the position and length of
            frame numbers.
          '';
        };
        use_file_extension = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Add the file format extensions to the rendered file name (eg: filename + .jpg).
          '';
        };
        pixel_aspect_x = mkOption {
          type = types.nullOr (types.numbers.between 1 200);
          default = null;
          description = ''
            Horizontal aspect ratio - for anamorphic or non-square pixel output.
          '';
        };
        pixel_aspect_y = mkOption {
          type = types.nullOr (types.numbers.between 1 200);
          default = null;
          description = ''
            Vertical aspect ratio - for anamorphic or non-square pixel output.
          '';
        };
        resolution_percentage = mkOption {
          type = types.nullOr (types.ints.between 1 32767);
          default = null;
          description = ''
            Percentage scale for render resolution.
          '';
        };
        resolution_x = mkOption {
          type = types.nullOr (types.ints.between 4 65536);
          default = null;
          description = ''
            Number of horizontal pixels in the rendered image.
          '';
        };
        resolution_y = mkOption {
          type = types.nullOr (types.ints.between 4 65536);
          default = null;
          description = ''
            Number of vertical pixels in the rendered image.
          '';
        };
        use_border = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Render Region

            Render a user-defined render region, within the frame size.
          '';
        };
        border_max_x = mkOption {
          type = types.nullOr (types.numbers.between 0 1);
          default = null;
          description = ''
            Maximum X value for the render region.
          '';
        };
        border_max_y = mkOption {
          type = types.nullOr (types.numbers.between 0 1);
          default = null;
          description = ''
            Maximum Y value for the render region.
          '';
        };
        border_min_x = mkOption {
          type = types.nullOr (types.numbers.between 0 1);
          default = null;
          description = ''
            Minimum X value for the render region.
          '';
        };
        border_min_y = mkOption {
          type = types.nullOr (types.numbers.between 0 1);
          default = null;
          description = ''
            Minimum Y value for the render region.
          '';
        };
        use_crop_to_border = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Crop to Render Region

            Crop the rendered frame to the defined render region size.
          '';
        };
        use_high_quality_normals = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use high quality tangent space at the cost of lower performance.
          '';
        };
        image_settings = {
          cineon_black = mkOption {
            type = types.nullOr (types.ints.between 0 1024);
            default = null;
            description = ''
              Log conversion reference blackpoint.
            '';
          };
          cineon_gamma = mkOption {
            type = types.nullOr (types.numbers.between 0 10);
            default = null;
            description = ''
              Log conversion gamma.
            '';
          };
          cineon_white = mkOption {
            type = types.nullOr (types.ints.between 0 1024);
            default = null;
            description = ''
              Log conversion reference whitepoint.
            '';
          };
          color_depth = mkOption {
            type = types.nullOr (types.enum ["8" "10" "12" "16" "32"]);
            default = null;
            description = ''
              Bit depth per channel.
            '';
          };
          color_management = mkOption {
            type = types.nullOr (types.enum ["FOLLOW_SCENE" "OVERRIDE"]);
            default = null;
            description = ''
              Which color management settings to use for file saving.
            '';
          };
          color_mode = mkOption {
            type = types.nullOr (types.enum ["BW" "RGB" "RGBA"]);
            default = null;
            description = ''
              Choose BW for saving grayscale images, RGB for saving red, green and blue channels,
              and RGBA for saving red, green, blue and alpha channels.
            '';
          };
          compression = mkOption {
            type = types.nullOr (types.ints.between 0 100);
            default = null;
            description = ''
              Amount of time to determine best compression: 0 = no compression with fast file
              output, 100 = maximum lossless compression with slow file output.
            '';
          };
          exr_codec = mkOption {
            type = types.nullOr (types.enum ["NONE" "PXR24" "ZIP" "PIZ" "RLE" "ZIPS" "B44" "B44A" "DWAA" "DWAB"]);
            default = null;
            description = ''
              Codec settings for OpenEXR.
            '';
          };
          file_format = mkOption {
            type = types.nullOr (types.enum [
              "BMP"
              "IRIS"
              "PNG"
              "JPEG"
              "JPEG2000"
              "TARGA"
              "TARGA_RAW"
              "CINEON"
              "DPX"
              "OPEN_EXR_MULTILAYER"
              "OPEN_EXR"
              "HDR"
              "TIFF"
              "WEBP"
            ]);
            default = null;
            description = ''
              File format to save the rendered images as.
            '';
          };
          has_linear_colorspace = mkOption {
            type = types.nullOr (types.bool);
            default = null;
            description = ''
              File format expects linear color space.
            '';
          };
          jpeg2k_codec = mkOption {
            type = types.nullOr (types.enum ["JP2" "J2K"]);
            default = null;
            description = ''
              Codec settings for Jpeg2000.
            '';
          };
          quality = mkOption {
            type = types.nullOr (types.ints.between 0 100);
            default = null;
            description = ''
              Quality for image formats that support lossy compression.
            '';
          };
          tiff_codec = mkOption {
            type = types.nullOr (types.enum ["NONE" "DEFLATE" "LZW" "PACKBITS"]);
            default = null;
            description = ''
              Compression mode for TIFF.
            '';
          };
          use_cineon_log = mkOption {
            type = types.nullOr (types.bool);
            default = null;
            description = ''
              Convert to logarithmic color space.
            '';
          };
          use_jpeg2k_cinema_48 = mkOption {
            type = types.nullOr (types.bool);
            default = null;
            description = ''
              Use Openjpeg Cinema Preset (48fps).
            '';
          };
          use_jpeg2k_cinema_preset = mkOption {
            type = types.nullOr (types.bool);
            default = null;
            description = ''
              Use Openjpeg Cinema Preset.
            '';
          };
          use_jpeg2k_ycc = mkOption {
            type = types.nullOr (types.bool);
            default = null;
            description = ''
              Save luminance-chrominance-chrominance channels instead of RGB colors.
            '';
          };
        };
      };
      cycles_curves = {
        shape = mkOption {
          type = types.nullOr (types.enum ["RIBBONS" "THICK"]);
          default = null;
          description = ''
            Shape

            Form of curves.

            RIBBONS: Render curves as flat ribbons with rounded normals, for fast rendering.
            THICK: Render curves as circular 3D geometry, for accurate results when viewing
              closely.
          '';
        };

        subdivisions = mkOption {
          type = types.nullOr (types.ints.between 0 24);
          default = null;
          description = ''
            Subdivisions

            Number of subdivisions used in Cardinal curve intersection (power of 2).
          '';
        };
      };
      cycles = {
        device = mkOption {
          type = types.nullOr (types.enum ["CPU" "GPU"]);
          default = null;
          description = ''
            Device

            Device to use for rendering.

            CPU: Use CPU for rendering.
            GPU: Use GPU compute device for rendering, configured in the system tab in the user
              preferences.
          '';
        };
        feature_set = mkOption {
          type = types.nullOr (types.enum ["SUPPORTED" "EXPERIMENTAL"]);
          default = null;
          description = ''
            Feature Set

            Feature set to use for rendering.

            SUPPORTED: Only use finished and supported features.
            EXPERIMENTAL: Use experimental and incomplete features that might be broken or change
              in the future.
          '';
        };
        shading_system = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Open Shading Language

            Use Open Shading Language.
          '';
        };
        use_denoising = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Denoising

            Denoised the rendered image.
          '';
        };
        denoiser = mkOption {
          type = types.nullOr (types.enum ["OPTIX" "OPENIMAGEDENOISE"]);
          default = null;
          description = ''
            Denoiser

            Denoiser to use for denoising.

            OPTIX: Use the OptiX AI denoiser with GPU acceleration, only available on NVIDIA GPUs.
            OPENIMAGEDENOISE: Use Intel OpenImageDenoise AI denoiser running on the CPU.
          '';
        };
        denoising_prefilter = mkOption {
          type = types.nullOr (types.enum ["NONE" "FAST" "ACCURATE"]);
          default = null;
          description = ''
            Denoising Prefilter

            Prefilter noisy guiding (albedo and normal) passes to improve denoising quality when
            using OpenImageDenoiser.

            NONE: No prefiltering, use when guiding passes are noise-free.
            FAST: Denoise color and guiding passes together. Improves quality when guiding passes
              are noisy using least amount of extra processing time.
            ACCURATE: Prefilter noisy guiding passes before denoising color. Improves quality when
              guiding passes are noisy using extra processing time.
          '';
        };
        denoising_input_passes = mkOption {
          type = types.nullOr (types.enum ["RGB" "RGB_ALBEDO" "RGB_ALBEDO_NORMAL"]);
          default = null;
          description = ''
            Denoising Input Passes

            Passes used by the denoiser to distinguish noise from shader and geometry detail.

            RGB: Don't use utility passes for denoising.
            RGB_ALBEDO: Use albedo pass for denoising.
            RGB_ALBEDO_NORMAL: Use albedo and normal passes for denoising.
          '';
        };
        samples = mkOption {
          type = types.nullOr (types.ints.between 1 16777216);
          default = null;
          description = ''
            Samples

            Number of samples to render for each pixel.
          '';
        };
        sample_offset = mkOption {
          type = types.nullOr (types.ints.between 0 16777216);
          default = null;
          description = ''
            Sample Offset

            Number of samples to skip when starting to render.
          '';
        };
        time_limit = mkOption {
          type = types.nullOr (types.numbers.nonnegative);
          default = null;
          description = ''
            Time Limit

            Limit the render time (excluding synchronization time). Zero disables the limit.
          '';
        };
        sampling_pattern = mkOption {
          type = types.nullOr (types.enum ["SOBOL_BURLEY" "TABULATED_SOBOL"]);
          default = null;
          description = ''
            Sampling Pattern

            Random sampling pattern used by the integrator.

            SOBOL_BURLEY: Use on-the-fly computed Owen-scrambled Sobol for random sampling.
            TABULATED_SOBOL: Use pre-computed tables of Owen-scrambled Sobol for random sampling.
          '';
        };
        scrambling_distance = mkOption {
          type = types.nullOr (types.numbers.nonnegative);
          default = null;
          description = ''
            Scrambling Distance

            Reduce randomization between pixels to improve GPU rendering performance, at the cost
            of possible rendering artifacts if set too low.
          '';
        };
        auto_scrambling_distance = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Automatic Scrambling Distance

            Automatically reduce the randomization between pixels to improve GPU rendering
            performance, at the cost of possible rendering artifacts.
          '';
        };
        use_layer_samples = mkOption {
          type = types.nullOr (types.enum ["USE" "BOUNDED" "IGNORE"]);
          default = null;
          description = ''
            Layer Samples

            How to use per view layer sample settings.

            USE: Per render layer number of samples override scene samples.
            BOUNDED: Bound per render layer number of samples by global samples.
            IGNORE: Ignore per render layer number of samples.
          '';
        };
        light_sampling_threshold = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0);
          default = null;
          description = ''
            Light Sampling Threshold

            Probabilistically terminate light samples when the light contribution is below this
            threshold (more noise but faster rendering). Zero disables the test and never ignores
            lights.
          '';
        };
        use_adaptive_sampling = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Adaptive Sampling

            Automatically reduce the number of samples per pixel based on estimated noise level.
          '';
        };
        adaptive_threshold = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0);
          default = null;
          description = ''
            Adaptive Sampling Threshold

            Noise level step to stop sampling at, lower values reduce noise at the cost of render
            time. Zero for automatic setting based on number of AA samples.
          '';
        };
        adaptive_min_samples = mkOption {
          type = types.nullOr (types.ints.between 0 4096);
          default = null;
          description = ''
            Adaptive Min Samples

            Minimum AA samples for adaptive sampling, to discover noisy features before stopping
            sampling. Zero for automatic setting based on noise threshold.
          '';
        };
        direct_light_sampling_type = mkOption {
          type = types.nullOr (types.enum ["MULTIPLE_IMPORTANCE_SAMPLING" "FORWARD_PATH_TRACING" "NEXT_EVENT_ESTIMATION"]);
          default = null;
          description = ''
            Direct Light Sampling

            The type of strategy used for sampling direct light contributions.

            MULTIPLE_IMPORTANCE_SAMPLING: Multiple importance sampling is used to combine direct
              light contributions from next-event estimation and forward path tracing.
            FORWARD_PATH_TRACING: Direct light contributions are only sampled using forward path
              tracing.
            NEXT_EVENT_ESTIMATION: Direct light contributions are only sampled using next-event
              estimation.
          '';
        };
        use_light_tree = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Light Tree

            Sample multiple lights more efficiently based on estimated contribution at every shading point.
          '';
        };
        min_light_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Min Light Bounces

            Minimum number of light bounces. Setting this higher reduces noise in the first
            bounces, but can also be less efficient for more complex geometry like curves and
            volumes.
          '';
        };
        min_transparent_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Min Transparent Bounces

            Minimum number of transparent bounces. Setting this higher reduces noise in the first
            bounces, but can also be less efficient for more complex geometry like curves and
            volumes.
          '';
        };
        caustics_reflective = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Reflective Caustics

            Use reflective caustics, resulting in a brighter image (more noise but added realism).
          '';
        };
        caustics_refractive = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Refractive Caustics

            Use refractive caustics, resulting in a brighter image (more noise but added realism).
          '';
        };
        blur_glossy = mkOption {
          type = types.nullOr (types.numbers.between 0.0 10.0);
          default = null;
          description = ''
            Filter Glossy

            Adaptively blur glossy shaders after blurry bounces, to reduce noise at the cost of
            accuracy.
          '';
        };
        use_guiding = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Guiding

            Use path guiding for sampling paths. Path guiding incrementally learns the light
            distribution of the scene and guides path into directions with high direct and
            indirect light contributions.
          '';
        };
        use_deterministic_guiding = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Deterministic

            Makes path guiding deterministic which means renderings will be reproducible with the
            same pixel values every time. This feature slows down training.
          '';
        };
        guiding_distribution_type = mkOption {
          type = types.nullOr (types.enum ["PARALLAX_AWARE_VMM" "DIRECTIONAL_QUAD_TREE" "VMM"]);
          default = null;
          description = ''
            Guiding Distribution Type

            Type of representation for the guiding distribution.

            PARALLAX_AWARE_VMM: Use Parallax-aware von Mises-Fisher models as directional
              distribution.
            DIRECTIONAL_QUAD_TREE: Use Directional Quad Trees as directional distribution.
            VMM: Use von Mises-Fisher models as directional distribution.
          '';
        };
        use_surface_guiding = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Surface Guiding

            Use guiding when sampling directions on a surface.
          '';
        };
        surface_guiding_probability = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0);
          default = null;
          description = ''
            Surface Guiding Probability

            The probability of guiding a direction on a surface.
          '';
        };
        use_volume_guiding = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Volume Guiding

            Use guiding when sampling directions inside a volume.
          '';
        };
        guiding_training_samples = mkOption {
          type = types.nullOr (types.ints.between 0 128);
          default = null;
          description = ''
            Training Samples

            The maximum number of samples used for training path guiding. Higher samples lead to
            more accurate guiding, however may also unnecessarily slow down rendering once guiding
            is accurate enough. A value of 0 will continue training until the last sample.
          '';
        };
        volume_guiding_probability = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0);
          default = null;
          description = ''
            Volume Guiding Probability

            The probability of guiding a direction inside a volume.
          '';
        };
        use_guiding_direct_light = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Guide Direct Light

            Consider the contribution of directly visible light sources during guiding.
          '';
        };
        use_guiding_mis_weights = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use MIS Weights

            Use the MIS weight to weight the contribution of directly visible light sources during
            guiding.
          '';
        };
        max_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Max Bounces

            Total maximum number of bounces.
          '';
        };
        diffuse_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Diffuse Bounces

            Maximum number of diffuse reflection bounces, bounded by total maximum.
          '';
        };
        glossy_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Glossy Bounces

            Maximum number of glossy reflection bounces, bounded by total maximum.
          '';
        };
        transmission_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Transmission Bounces

            Maximum number of transmission bounces, bounded by total maximum.
          '';
        };
        volume_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Volume Bounces

            Maximum number of volume scattering events, bounded by total maximum.
          '';
        };
        transparent_max_bounces = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            Transparent Max Bounces

            Maximum number of transparent bounces. This is independent of maximum number of other
            bounces.
          '';
        };
        volume_step_rate = mkOption {
          type = types.nullOr (types.numbers.between 0.01 100.0);
          default = null;
          description = ''
            Step Rate

            Globally adjust detail for volume rendering, on top of automatically estimated step
            size. Higher values reduce render time, lower values render with more detail.
          '';
        };
        volume_max_steps = mkOption {
          type = types.nullOr (types.ints.between 2 65536);
          default = null;
          description = ''
            Max Steps

            Maximum number of steps through the volume before giving up, to avoid extremely long
            render times with big objects or small step sizes.
          '';
        };
        dicing_rate = mkOption {
          type = types.nullOr (types.numbers.between 0.1 1000.0);
          default = null;
          description = ''
            Dicing Rate

            Size of a micropolygon in pixels.
          '';
        };
        max_subdivisions = mkOption {
          type = types.nullOr (types.ints.between 0 16);
          default = null;
          description = ''
            Max Subdivisions

            Stop subdividing when this level is reached even if the dice rate would produce finer
            tessellation.
          '';
        };
        offscreen_dicing_scale = mkOption {
          type = types.nullOr (types.numbers.between 0.1 1000.0);
          default = null;
          description = ''
            Offscreen Dicing Scale

            Multiplier for dicing rate of geometry outside of the camera view. The dicing rate of
            objects is gradually increased the further they are outside the camera view. Lower
            values provide higher quality reflections and shadows for off screen objects, while
            higher values use less memory
          '';
        };
        film_exposure = mkOption {
          type = types.nullOr (types.numbers.between 0.0 10.0);
          default = null;
          description = ''
            Exposure

            Image brightness scale.
          '';
        };
        film_transparent_glass = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Transparent Glass

            Render transmissive surfaces as transparent, for compositing glass over another
            background.
          '';
        };
        film_transparent_rougness = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0);
          default = null;
          description = ''
            Transparent Roughness Threshold

            For transparent transmission, keep surfaces with roughness above the threshold opaque.
          '';
        };
        pixel_filter_type = mkOption {
          type = types.nullOr (types.enum [
            "BOX"
            "GAUSSIAN"
            "BLACKMAN_HARRIS"
          ]);
          default = null;
          description = ''
            Filter Type

            Pixel filter type.

            BOX: Box filter.
            GAUSSIAN: Gaussian filter.
            BLACKMAN_HARRIS: Blackman-Harris filter.
          '';
        };
        filter_width = mkOption {
          type = types.nullOr (types.numbers.between 0.01 10.0);
          default = null;
          description = ''
            Filter Width

            Pixel filter width.
          '';
        };

        seed = mkOption {
          type = types.nullOr (types.ints.between 0 2147483647);
          default = null;
          description = ''
            Seed

            Seed value for integrator to get different noise patterns.
          '';
        };

        use_animated_seed = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Animated Seed

            Use different seed values (and hence noise patterns) at different frames.
          '';
        };
        sample_clamp_direct = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0e8);
          default = null;
          description = ''
            Clamp Direct

            If non-zero, the maximum value for a direct sample, higher values will be scaled down
            to avoid too much noise and slow convergence at the cost of accuracy.
          '';
        };
        sample_clamp_indirect = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0e8);
          default = null;
          description = ''
            Clamp Indirect

            If non-zero, the maximum value for an indirect sample, higher values will be scaled
            down to avoid too much noise and slow convergence at the cost of accuracy.
          '';
        };
        debug_use_spatial_splits = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Spatial Splits

            Use BVH spatial splits: longer builder time, faster render.
          '';
        };
        debug_use_hair_bvh = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Curves BVH

            Use special type BVH optimized for curves (uses more ram but renders faster).
          '';
        };
        debug_use_compact_bvh = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Compact BVH

            Use compact BVH structure (uses less ram but renders slower).
          '';
        };
        debug_bvh_time_steps = mkOption {
          type = types.nullOr (types.ints.between 0 16);
          default = null;
          description = ''
            BVH Time Steps

            Split BVH primitives by this number of time steps to speed up render time in cost of memory.
          '';
        };
        use_camera_cull = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Camera Cull

            Allow objects to be culled based on the camera frustum.
          '';
        };
        camera_cull_margin = mkOption {
          type = types.nullOr (types.numbers.between 0.0 5.0);
          default = null;
          description = ''
            Camera Cull Margin

            Margin for the camera space culling.
          '';
        };
        use_distance_cull = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Distance Cull

            Allow objects to be culled based on distance from camera.
          '';
        };
        distance_cull_margin = mkOption {
          type = types.nullOr (types.numbers.nonnegative);
          default = null;
          description = ''
            Cull Distance

            Cull objects which are further away from camera than this distance
          '';
        };
        motion_blur_position = mkOption {
          type = types.nullOr (types.enum [
            "START"
            "CENTER"
            "END"
          ]);
          default = null;
          description = ''
            Motion Blur Position

            Offset for the shutter's time interval, allows to change the motion blur trails.

            START: The shutter opens at the current frame.
            CENTER: The shutter is open during the current frame.
            END: The shutter closes at the current frame.
          '';
        };
        rolling_shutter_type = mkOption {
          type = types.nullOr (types.enum [
            "NONE"
            "TOP"
          ]);
          default = null;
          description = ''
            Shutter Type

            Type of rolling shutter effect matching CMOS-based cameras.

            NONE: No rolling shutter effect.
            TOP: Top to bottom rolling shutter effect.
          '';
        };
        rolling_shutter_duration = mkOption {
          type = types.nullOr (types.numbers.between 0.0 1.0);
          default = null;
          description = ''
            Rolling Shutter Duration

            Scanline "exposure" time for the rolling shutter effect.
          '';
        };
        texture_limit_render = mkOption {
          type = types.nullOr (types.enum [
            "OFF"
            "128"
            "256"
            "512"
            "1024"
            "2048"
            "4096"
            "8192"
          ]);
          default = null;
          description = ''
            Render Texture Limit

            Limit texture size used by final rendering.

            OFF: No texture size limit.
            128: Limit texture size to 128 pixels.
            256: Limit texture size to 256 pixels.
            512: Limit texture size to 512 pixels.
            1024: Limit texture size to 1024 pixels.
            2048: Limit texture size to 2048 pixels.
            4096: Limit texture size to 4096 pixels.
            8192: Limit texture size to 8192 pixels.
          '';
        };

        use_fast_gi = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Fast GI Approximation

            Approximate diffuse indirect light with background tinted ambient occlusion. This
            provides fast alternative to full global illumination, for interactive viewport
            rendering or final renders with reduced quality.
          '';
        };

        fast_gi_method = mkOption {
          type = types.nullOr (types.enum [
            "REPLACE"
            "ADD"
          ]);
          default = null;
          description = ''
            Fast GI Method

            Fast GI approximation method.

            REPLACE: Replace global illumination with ambient occlusion after a specified number
              of bounces.
            ADD: Add ambient occlusion to diffuse surfaces.
          '';
        };
        ao_bounces_render = mkOption {
          type = types.nullOr (types.ints.between 0 1024);
          default = null;
          description = ''
            AO Bounces Render

            After this number of light bounces, use approximate global illumination. 0 disables
            this feature.
          '';
        };
        use_auto_tile = mkOption {
          type = types.nullOr (types.bool);
          default = null;
          description = ''
            Use Tiling

            Render high resolution images in tiles to reduce memory usage, using the specified
            tile size. Tiles are cached to disk while rendering to save memory.
          '';
        };
        tile_size = mkOption {
          type = types.nullOr (types.ints.between 8 8192);
          default = null;
          description = ''
            Tile Size

            Size of the tiles used for rendering.
          '';
        };
      };
    };
  };
}
