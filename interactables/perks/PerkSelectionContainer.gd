class_name PerkSelectionContainer extends Control

signal onPerkSelected

func _ready() -> void:
	while get_child_count() > 0:
		var child := get_child(0)
		child.queue_free()
		remove_child(child)

func AddPerk(definition: Perk.Definition) -> PerkSelectionButton:
	var button := Asset.Instantiate(PerkSelectionButton) as PerkSelectionButton
	add_child(button)
	button.Setup(definition)
	button.perkSelected.connect(onPerkSelected.emit)
	return button
