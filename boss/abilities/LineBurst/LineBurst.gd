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
	await get_tree().create_timer(0.5).timeout
	$TriggerParticles.emitting = false
