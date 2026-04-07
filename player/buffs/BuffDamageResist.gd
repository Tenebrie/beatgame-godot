class_name BuffDamageResist extends Buff

func _ready() -> void:
	SignalBus.OnFullBeat.connect(func(_beat: float):
		queue_free()
	)
