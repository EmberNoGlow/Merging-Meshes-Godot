@tool
@icon("res://addons/mergingmeshes/icons8-mesh-32.png")
extends Node3D


@export_tool_button("Generate Merged Mesh")
var generate_action = generate_merged_mesh

@export_tool_button("Clear Merged Mesh")
var clear_action = clear_merged_mesh

@export var generate_at_runtime: bool = false

@export var meshes: Array[MeshInstance3D] = []

@export_group("Merge Settings")

@export var hide_source_meshes: bool = true
@export var use_original_materials: bool = true
@export var general_material: BaseMaterial3D

# Generates indexed geometry to reduce duplicated vertices.
@export var generate_indices: bool = true

# Automatically skips invisible meshes.
@export var ignore_hidden_meshes: bool = true

const MERGED_NODE_NAME := "MergedMeshInstance"

func _ready() -> void:
	# Runtime generation only.
	if Engine.is_editor_hint():
		return

	if not generate_at_runtime:
		return

	generate_merged_mesh()

func generate_merged_mesh() -> void:
	clear_merged_mesh()

	if meshes.is_empty():
		push_warning("Meshes array is empty.")
		return

	var merged_instance := create_merged_instance()

	if merged_instance == null:
		push_warning("Failed to create merged mesh.")
		return

	add_child(merged_instance)

	# Required so the node is saved into the scene in editor mode.
	if Engine.is_editor_hint():
		merged_instance.owner = get_tree().edited_scene_root

	if hide_source_meshes:
		hide_original_meshes()


func clear_merged_mesh() -> void:
	var old := get_node_or_null(MERGED_NODE_NAME)
	
	if old:
		old.free()
	
	restore_original_meshes()


func merge_multiple_meshes(meshes_to_merge: Array[MeshInstance3D]) -> ArrayMesh:
	var array_mesh := ArrayMesh.new()

	# Convert all meshes into local space of this node.
	var inverse_transform := global_transform.affine_inverse()

	# Material -> SurfaceTool
	var material_groups: Dictionary = {}
	
	for mesh_instance in meshes_to_merge:
	
		if not is_instance_valid(mesh_instance):
			continue
	
		if ignore_hidden_meshes and not mesh_instance.visible:
			continue
	
		if mesh_instance.mesh == null:
			continue
	
		var source_mesh: Mesh = mesh_instance.mesh
		var local_transform := inverse_transform * mesh_instance.global_transform

		for surface_index in source_mesh.get_surface_count():
			var material: Material = null
	
			if use_original_materials:
				material = mesh_instance.get_active_material(surface_index)

			if material == null:
				material = general_material

			# Create one SurfaceTool per material.
			if not material_groups.has(material):
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				material_groups[material] = st

			var surface_tool: SurfaceTool = material_groups[material]

			# Append mesh data into merged geometry.
			surface_tool.append_from(
				source_mesh,
				surface_index,
				local_transform
			)

	# Commit all surfaces.
	for material in material_groups:
		var surface_tool: SurfaceTool = material_groups[material]

		# Generate indexed geometry.
		if generate_indices:
			surface_tool.index()

		surface_tool.commit(array_mesh)

		array_mesh.surface_set_material(
			array_mesh.get_surface_count() - 1,
			material
		)

	return array_mesh


func create_merged_instance() -> MeshInstance3D:
	var merged_mesh := merge_multiple_meshes(meshes)
	
	if merged_mesh == null:
		return null
	
	var mesh_instance := MeshInstance3D.new()
	
	mesh_instance.name = MERGED_NODE_NAME
	mesh_instance.mesh = merged_mesh

	return mesh_instance


func hide_original_meshes() -> void:
	for mesh_instance in meshes:
		if is_instance_valid(mesh_instance):
			mesh_instance.visible = false


func restore_original_meshes() -> void:
	for mesh_instance in meshes:
		if is_instance_valid(mesh_instance):
			mesh_instance.visible = true
