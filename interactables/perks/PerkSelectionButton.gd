class_name PerkSelectionButton extends Control

@onready var container: Panel = $Panel
@onready var nameLabel: Label = $%NameLabel
@onready var descriptionLabel: RichTextLabel = $%DescriptionLabel
@onready var rarityLabel: Label = $%RarityLabel

signal perkSelected

var panelOffsetTween: Tween
var isHovering: bool
var isClicking: bool

func _ready() -> void:
	mouse_entered.connect(func() -> void:
		isHovering = true
		if panelOffsetTween:
			panelOffsetTween.kill()
		panelOffsetTween = create_tween()
		panelOffsetTween.set_parallel()
		panelOffsetTween.tween_property(container, "position", Vector2(-50.0, 0.0), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		var stylebox := container.get_theme_stylebox("panel") as StyleBoxFlat
		panelOffsetTween.tween_property(stylebox, "border_color", Color.ALICE_BLUE, 0.05).set_ease(Tween.EASE_OUT)
	)
	mouse_exited.connect(func() -> void:
		if isClicking:
			return
		isHovering = false
		if panelOffsetTween:
			panelOffsetTween.kill()
		panelOffsetTween = create_tween()
		panelOffsetTween.set_parallel()
		panelOffsetTween.tween_property(container, "position", Vector2(0, 0), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		var stylebox := container.get_theme_stylebox("panel") as StyleBoxFlat
		panelOffsetTween.tween_property(stylebox, ^"border_color", Color.from_string("#100526", Color.WHITE), 0.1).set_ease(Tween.EASE_OUT)
	)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed and isHovering:
		isClicking = true
	elif event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and not event.pressed and isHovering and isClicking:
		triggerClick()
		isClicking = false
		mouse_exited.emit()
		perkSelected.emit()

	if event is InputEventMouseButton and not event.pressed:
		isClicking = false

func triggerClick() -> void:
	perkDefinition.InstantiateForPlayer()

var perkDefinition: Perk.Definition

func Setup(definition: Perk.Definition) -> void:
	perkDefinition = definition
	nameLabel.text = definition.perkName
	descriptionLabel.text = definition.perkDescription
	rarityLabel.text = rarityToString(definition.rarity)

func rarityToString(rarity: Perk.Rarity) -> String:
	if rarity == Perk.Rarity.Common:
		return "Common"
	elif rarity == Perk.Rarity.Rare:
		return "Rare"
	elif rarity == Perk.Rarity.Epic:
		return "Epic"
	elif rarity == Perk.Rarity.Legendary:
		return "Legendary"
	elif rarity == Perk.Rarity.Unique:
		return "Unique"
	else:
		return ""
