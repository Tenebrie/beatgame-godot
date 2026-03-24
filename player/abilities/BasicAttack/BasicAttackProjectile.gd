class_name BasicAttackProjectile extends Node3D


func _process(delta: float) -> void:
	position += Vector3(delta * 12.0, 0.0, 0.0)
