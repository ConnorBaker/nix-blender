{
  blenderConfig,
  lib,
  writers,
}: let
in
  writers.writePython3 "blender_config.py" {
    flakeIgnore = ["E501"];
  }
  ''
    import bpy
    ${concatStringsSep "\n" (genConfigLines "bpy.context" checkedConfig)}
    bpy.ops.render.render(write_still=True)
  ''
