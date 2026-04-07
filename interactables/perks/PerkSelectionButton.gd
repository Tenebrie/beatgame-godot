class_name PerkSelectionButton extends Control

@onready var container: Panel = $Panel
@onready var nameLabel: Label = $%NameLabel
@onready var descriptionLabel: RichTextLabel = $%DescriptionLabel
@onready var rarityLabel: Label = $%RarityLabel

signal perkSelected

var panelOffsetTween: Tween
var isHovering: bool
var isClicking: bool

var perkDefinition: Perk.Definition

func _ready() -> void:
	mouse_entered.connect(func() -> void:
		isHovering = true
		if panelOffsetTween:
			panelOffsetTween.kill()
		panelOffsetTween = create_tween()
		panelOffsetTween.set_parallel()
		panelOffsetTween.tween_property(container, "position", Vector2(-50.0, 0.0), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		var stylebox := container.get_theme_stylebox("panel") as StyleBoxFlat
		panelOffsetTween \
			.tween_property(stylebox, "border_color", rarityToHighlight(perkDefinition.rarity), 0.05) \
			.set_ease(Tween.EASE_OUT)
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
		panelOffsetTween \
			.tween_property(stylebox, ^"border_color", rarityToBackground(perkDefinition.rarity), 0.1) \
			.set_ease(Tween.EASE_OUT)
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

func Setup(definition: Perk.Definition) -> void:
	definition = definition.Update()
	perkDefinition = definition
	nameLabel.text = definition.perkName
	descriptionLabel.text = definition.perkDescription
	rarityLabel.text = rarityToString(definition.rarity)
	var stylebox := container.get_theme_stylebox("panel") as StyleBoxFlat
	stylebox.bg_color = rarityToBackground(definition.rarity)
	stylebox.border_color = rarityToBackground(definition.rarity)

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

func rarityToBackground(rarity: Perk.Rarity) -> Color:
	match rarity:
		Perk.Rarity.Common:    return Color(0.25, 0.27, 0.30)   # slate grey
		Perk.Rarity.Rare:      return Color(0.12, 0.23, 0.48)   # deep blue
		Perk.Rarity.Epic:      return Color(0.35, 0.12, 0.48)   # dark purple
		Perk.Rarity.Legendary: return Color(0.55, 0.35, 0.08)   # burnished gold
		Perk.Rarity.Unique:    return Color(0.10, 0.42, 0.40)   # deep teal
		_:                     return Color.BLACK

func rarityToHighlight(rarity: Perk.Rarity) -> Color:
	match rarity:
		Perk.Rarity.Common:    return Color(0.70, 0.73, 0.78)   # bright silver
		Perk.Rarity.Rare:      return Color(0.30, 0.55, 1.00)   # electric blue
		Perk.Rarity.Epic:      return Color(0.75, 0.30, 1.00)   # neon purple
		Perk.Rarity.Legendary: return Color(1.00, 0.80, 0.15)   # blazing gold
		Perk.Rarity.Unique:    return Color(0.15, 1.00, 0.90)   # cyan punch
		_:                     return Color.WHITE
