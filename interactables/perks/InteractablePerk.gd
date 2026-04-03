class_name InteractablePerk extends Interactable

@onready var perkSelectionContainer: PerkSelectionContainer = $%PerkSelectionContainer

signal perkSelected

func _ready() -> void:
	super._ready()
	$PerksUI.visible = false
	onActivated.connect(func() -> void:
		generatePerks()
	)
	perkSelectionContainer.onPerkSelected.connect(func() -> void:
		DisableInteraction()
		$PerksUI.visible = false
		perkSelected.emit()
		$GPUParticles3DGlow.emitting = false
		$GPUParticles3DMix.emitting = false
		await get_tree().create_timer(0.5).timeout
		create_tween().tween_property($MeshInstance3D, ^"position", Vector3(0, -1, 0), 1.0).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(2).timeout
		queue_free()
	)

func generatePerks() -> void:
	var perkOne := PerkBasicClaws.Build()
	var perkTwo := PerkBasicFireball.Build()
	perkSelectionContainer.AddPerk(perkOne)
	perkSelectionContainer.AddPerk(perkTwo)

	$PerksUI.visible = true
