@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"MergingMeshes", "MeshInstance3D",
		preload("res://addons/mergingmeshes/MergingMeshes.gd"),
		preload("res://addons/mergingmeshes/icons8-mesh-32.png")
	)


func _exit_tree():
	remove_custom_type("MergingMeshes")
