from __future__ import annotations
import bpy  # type: ignore[import]
from typing import Type, Union
import json

JSONObject = dict[
    str, Union[None, bool, int, float, str, list["JSONObject"], "JSONObject"]
]
d: JSONObject = json.load(open("config.json", "r"))


def set_props(obj: object, d: JSONObject) -> None:
    for key, value in d.items():
        if value is None:
            continue
        elif isinstance(value, (bool, int, float, str)):
            print(f"Setting {key} to {value}")
            setattr(obj, key, value)
        elif isinstance(value, dict):
            if hasattr(obj, "__getitem__"):
                # Handle special case of collections
                set_props(obj[key], value)
            else:
                set_props(getattr(obj, key), value)
        else:
            raise ValueError(
                f"Unexpected value {value} of type {type(value)} for key {key}"
            )


set_props(bpy.context, d)

# Render the scene
bpy.ops.render.render(write_still=True)
