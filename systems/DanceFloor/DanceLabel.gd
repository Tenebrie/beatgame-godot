## Dynamically generated row or column label for DanceFloor
##
## Not intended for public use
@icon("res://assets/icons/editor/Cross.svg")
class_name DanceLabel extends Node3D

func set_text(label: String) -> void:
	var mesh := $MeshInstance3D.mesh as TextMesh
	mesh.text = label
