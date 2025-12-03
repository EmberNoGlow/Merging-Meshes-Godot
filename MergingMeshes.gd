@icon("res://addons/mergingmeshes/icons8-mesh-32.png")
extends Node3D

@export var meshes : Array[MeshInstance3D]
@export var GeneralMaterial : BaseMaterial3D
@export var HideSource : bool = true


func merge_multiple_meshes(meshes_to_merge: Array) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for mesh_instance in meshes_to_merge:
		if mesh_instance is MeshInstance3D and mesh_instance.mesh:
			var transform: Transform3D = mesh_instance.global_transform
			for i in range(mesh_instance.mesh.get_surface_count()):
				surface_tool.append_from(mesh_instance.mesh, i, transform)

	surface_tool.commit(array_mesh)

	return array_mesh


func _ready():
	var new_mesh = merge_multiple_meshes(meshes)
	var inst = MeshInstance3D.new()
	add_child(inst)
	inst.mesh = new_mesh
	if GeneralMaterial != null:
		inst.material_override = GeneralMaterial
	if HideSource:
		for i in meshes:
			i.visible = false
