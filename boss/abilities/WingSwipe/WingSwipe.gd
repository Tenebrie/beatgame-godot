class_name WingSwipe extends BossCast

@export var direction: int = 0

func _ready() -> void:
	$TriggerParticles.emitting = false
	$TelegraphParticles.emitting = false
	set_direction(direction)

func start_telegraph() -> void:
	$TelegraphParticles.emitting = true
	pass

func trigger() -> void:
	$TelegraphParticles.emitting = false
	$TriggerParticles.emitting = true
	await get_tree().create_timer(0.5).timeout
	$TriggerParticles.emitting = false

func set_direction(dir: int) -> void:
	if dir == 0:
		rotation_degrees = Vector3(0.0, 0.0, 0.0)
	elif dir == 1:
		rotation_degrees = Vector3(0.0, 180.0, 0.0)
