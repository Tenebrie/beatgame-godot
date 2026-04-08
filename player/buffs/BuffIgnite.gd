class_name BuffIgnite extends Buff

static func GetDamage() -> float:
	return 0.125

func _ready() -> void:
	SignalBus.OnAnyBeat.connect(onBeat)
	var effect := preload("res://player/buffs/BuffIgniteEffect.tscn").instantiate()
	add_child(effect)
	position = Vector3(randf_range(-0.125, 0.125), 0.0, randf_range(-0.125, 0.125))

	dancer.onDeath.connect(func() -> void:
		effect.get_child(0).emitting = false
	)

func onBeat(beat: float) -> void:
	if is_equal_approx(beat - floorf(beat), 0.5):
		dancer.DealDamage(GetDamage())
