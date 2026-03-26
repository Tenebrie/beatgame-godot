class_name LineBurst extends BossCast

func _ready() -> void:
	$TriggerParticles.emitting = false
	$TelegraphParticles.emitting = false

func start_telegraph() -> void:
	$TelegraphParticles.emitting = true
	pass

func trigger() -> void:
	$TelegraphParticles.emitting = false
	$TriggerParticles.restart()
	$TriggerParticles.emitting = true
	apply_damage_to_all()
	await get_tree().create_timer(0.5).timeout
	$TriggerParticles.emitting = false
	
func apply_damage_to_all() -> void:
	var overlapping: Array[Area3D] = $Area3D.get_overlapping_areas()
	for area: Area3D in overlapping:
		if area.get_parent() is Player:
			apply_damage_to_target(area.get_parent())
			
func apply_damage_to_target(target: Player) -> void:
	if dealsDamage:
		target.DealDamage(2.0)

var dealsDamage := true
func DisableDamage() -> void:
	dealsDamage = false
