class_name PerkBasicFireballPlayerEffect extends Node3D

#func _ready() -> void:
	#SetEmitting(false)
	#SignalBus.OnFightBegin.connect(func() -> void: SetEmitting(true))

func SetEmitting(emitting: bool) -> void:
	$GPUParticles3D.emitting = emitting
