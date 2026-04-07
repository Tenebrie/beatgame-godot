class_name BuffRooted extends Buff

func _ready() -> void:
	SignalBus.OnHalfBeat.connect(func(_beat: float):
		queue_free()
	)
