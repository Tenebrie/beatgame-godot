class_name DanceLabel extends Node3D

func set_text(label: String) -> void:
	var mesh := $MeshInstance3D.mesh as TextMesh
	mesh.text = label
