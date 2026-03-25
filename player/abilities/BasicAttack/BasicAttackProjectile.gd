class_name BasicAttackProjectile extends Node3D

func _process(delta: float) -> void:
	var forward := -global_transform.basis.z
	global_position += forward * 12.0 * delta
