@icon("res://addons/mergingmeshes/icons8-mesh-32.png")
extends Node3D

@export var meshes : Array[MeshInstance3D]
@export var HideSource : bool = true
@export var UseOriginalMaterials : bool = true
@export var GeneralMaterial : BaseMaterial3D

func merge_multiple_meshes(meshes_to_merge: Array) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()

	# If we want to keep original materials, we group by material
	# Otherwise, we merge everything into one surface
	if GeneralMaterial and not UseOriginalMaterials:
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		for mesh_instance in meshes_to_merge:
			if mesh_instance is MeshInstance3D and mesh_instance.mesh:
				# Get transform relative to THIS node (the parent of the merged mesh)
				var local_xform: Transform3D = self.global_transform.affine_inverse() * mesh_instance.global_transform
				
				for i in range(mesh_instance.mesh.get_surface_count()):
					# append_from automatically handles UVs, Normals, and Tangents 
					# if they exist in the source mesh.
					surface_tool.append_from(mesh_instance.mesh, i, local_xform)
		
		# Optional: Optimize the mesh by joining identical vertices
		surface_tool.index() 
		surface_tool.commit(array_mesh)
		array_mesh.surface_set_material(0, GeneralMaterial)
	
	else:
		# Logic for preserving multiple materials
		for mesh_instance in meshes_to_merge:
			if not mesh_instance or not mesh_instance.mesh: continue
			
			var local_xform: Transform3D = self.global_transform.affine_inverse() * mesh_instance.global_transform
			
			for i in range(mesh_instance.mesh.get_surface_count()):
				surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				var mat = mesh_instance.get_active_material(i)
				surface_tool.append_from(mesh_instance.mesh, i, local_xform)
				surface_tool.index()
				surface_tool.commit(array_mesh)
				# Set the material for the surface we just added
				array_mesh.surface_set_material(array_mesh.get_surface_count() - 1, mat)

	return array_mesh

func _ready():
	if meshes.is_empty():
		return

	var new_mesh = merge_multiple_meshes(meshes)
	var inst = MeshInstance3D.new()
	inst.name = "MergedMeshInstance"
	add_child(inst)
	inst.mesh = new_mesh
	
	if HideSource:
		for i in meshes:
			if i: i.visible = false
