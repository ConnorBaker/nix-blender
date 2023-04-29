# https://github.com/blender/blender/blob/f8e23e495b037a1e70e04406e421fa918a3d5bac/intern/cycles/blender/addon/properties.py#L601
# All of these take place in bpy.context
{
  blender,
  blenderConfig ? {},
  lib,
  nixGLNvidia,
  writeShellApplication,
}: let
  inherit
    (builtins)
    concatLists
    concatStringsSep
    isAttrs
    isFloat
    isInt
    isString
    throw
    toString
    typeOf
    ;
  inherit
    (lib)
    hasSuffix
    mapAttrsToList
    ;
  inherit (lib.strings) floatToString;

  checkedConfig = let
    # Wrap blenderConfig in a module so that we can use `imports`
    modularizedBlenderConfig = {config = blenderConfig;};
    modules = [./options.nix modularizedBlenderConfig];
    # Evaluate the modules
    inherit (lib.modules.evalModules {inherit modules;}) config;
  in
    config;

  # Generate a list of strings for a python program to set blender configiurations
  genConfigLines = acc_str: attrs:
    concatLists (
      mapAttrsToList (
        key: value:
          if value == null
          then []
          else if value == true
          then ["${acc_str}.${key} = True"]
          else if value == false
          then ["${acc_str}.${key} = False"]
          else if isInt value
          then ["${acc_str}.${key} = ${toString value}"]
          else if isFloat value
          then ["${acc_str}.${key} = ${floatToString value}"]
          else if isString value
          then ["${acc_str}.${key} = \"${value}\""]
          else if isAttrs value
          then
            genConfigLines (
              # Special case for addons because they are a collection and we must use `get`.
              if hasSuffix "preferences.addons" acc_str
              then "${acc_str}[\"${key}\"]"
              else "${acc_str}.${key}"
            )
            value
          else throw "Unsupported type for ${key}: ${typeOf value}"
      )
      attrs
    );
in
  writeShellApplication {
    name = "blender-headless-runner";
    runtimeInputs = [
      blender
      nixGLNvidia
    ];
    text = ''
      ${nixGLNvidia.name} blender --debug-cycles --debug-gpu --background --enable-autoexec -noaudio "$@" --python-expr \
      '
      import bpy
      for device in bpy.context.preferences.addons["cycles"].preferences.devices:
        device.use = device.type == "GPU"
      ${concatStringsSep "\n" (genConfigLines "bpy.context" checkedConfig)}
      bpy.ops.render.render(write_still=True)
      '
    '';
  }
