class_name BasicAttackProjectile extends Node3D

func _ready() -> void:
	$Area3D.area_entered.connect(OnCollision)
	await get_tree().create_timer(2.5).timeout
	queue_free()

func OnCollision(other: Area3D) -> void:
	if other.get_parent() is not Boss:
		return
	isDestroyed = true
	$GPUParticles3D.emitting = false
	create_tween().tween_property($OmniLight3D, ^"omni_range", 0.0, 0.5)
	create_tween().tween_property($MeshInstance3D, ^"scale", Vector3.ZERO, 0.2)
	var boss := other.get_parent() as Boss
	boss.DealDamage(1.0)
	await get_tree().create_timer(0.5).timeout
	queue_free()

var isDestroyed := false

func _process(delta: float) -> void:
	if isDestroyed:
		return
	var forward := -global_transform.basis.z
	global_position += forward * 12.0 * delta
