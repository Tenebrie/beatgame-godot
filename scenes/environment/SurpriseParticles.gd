extends Node3D

func _ready() -> void:
	SignalBus.StartEmittingSurpriseParticles.connect(func() -> void:
		$GPUParticles3D.emitting = true
	)
