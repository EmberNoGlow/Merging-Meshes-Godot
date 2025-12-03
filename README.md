# Merging Meshes Godot
Optimize your 3d scenes with Merging Meshes.



## What is it?
Merging Meshes is an add-on for **Godot 4** that is designed to **optimize scenes** with a large number of **MeshInstance3D** and **procedural geometry**.

## How it works?
Meshes are combined by merging MeshInstance3D using SurfaceTool (append_from method). This allows you to combine an **unlimited number of meshes into one**, resulting in a **HUGE GROWTH in perfomance** as **only one drawing call is made instead of thousands**

## Usage

1.  Download and enable the addon from the Addon Manager.
2.  Add a `MergingMeshes` node to your scene.
3.  In the Inspector panel, add your `MeshInstance3D` nodes to the `meshes` parameter.
4.  Optional: Assign a `Material3D` to the `GeneralMaterial` parameter to set the material for the merged mesh.
5.  Recommended: Keep the `HideSource` parameter enabled to automatically hide the original `MeshInstance3D` nodes.


## Did you like the high FPS?
Consider **starring** this repository to make it easier for others to **find it**. Also, check out my [profile](https://github.com/EmberNoGlow) for **more Godot projects**!
