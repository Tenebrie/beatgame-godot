@tool
class_name DancerAttackChargeEffect extends DancerEffect

func _ready() -> void:
	onInit.connect(func() -> void:
		$GPUParticles3D.emitting = false
	)
	onCleanup.connect(func() -> void:
		StopCharging()
	)

	super._ready()


func StartCharging() -> void:
	$GPUParticles3D.emitting = true

func StopCharging() -> void:
	$GPUParticles3D.emitting = false
