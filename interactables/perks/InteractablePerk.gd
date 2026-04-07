class_name InteractablePerk extends Interactable

@onready var perkSelectionContainer: PerkSelectionContainer = $%PerkSelectionContainer

signal perkSelected

var skippingText := false
var currentAnimationTimer: SceneTreeTimer
var currentTweens: Array[Tween]

func _ready() -> void:
	super._ready()
	$PerksUI.visible = false
	onActivated.connect(func() -> void:
		initialize()
	)
	$%PerksPanel.gui_input.connect(func(input: InputEvent) -> void:
		if input is not InputEventMouseButton or not input.pressed:
			return

		var skipped := false
		if currentAnimationTimer and currentAnimationTimer.time_left > 0:
			currentAnimationTimer.time_left = 0
			skipped = true

		if currentTweens.size() > 0:
			currentTweens[0].custom_step(100000.0)
			skipped = true

		var perkContainer := $%PerkSelectionContainer as PerkSelectionContainer
		if perkContainer.IsAnimating():
			perkContainer.SkipAnimation()
			skipped = true

		if not skipped:
			skippingText = true
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

func initialize() -> void:
	var stylebox := $%PerksPanel.get_theme_stylebox("panel") as StyleBoxFlat
	var targetColor := Color(0.11, 0.07, 0.02, 0.95)
	stylebox.bg_color = Color(0.55, 0.35, 0.08, 0.0)
	var tween := create_tween()
	tween.tween_property(stylebox, ^"bg_color", Color(0.55, 0.35, 0.08), 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(stylebox, ^"bg_color", targetColor, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void:
		currentTweens.remove_at(currentTweens.find(tween))
	)
	currentTweens.append(tween)

	$PerksUI.visible = true
	var avatarPosition: Vector2 = $%AspectAvatar.position
	var namePosition: Vector2 = $%AspectName.position
	var titlePosition: Vector2 = $%AspectTitle.position
	$%AspectAvatar.position = avatarPosition - Vector2(300, 0)
	$%AspectAvatar.self_modulate = Color(Color.WHITE, 0.0)
	$%AspectName.position = namePosition - Vector2(100, 0)
	$%AspectName.self_modulate = Color(Color.WHITE, 0.0)
	$%AspectTitle.position = titlePosition - Vector2(100, 0)
	$%AspectTitle.self_modulate = Color(Color.WHITE, 0.0)

	$%AspectText.text = ""

	currentAnimationTimer = get_tree().create_timer(1.0)
	await currentAnimationTimer.timeout
	create_tween().tween_property($%AspectAvatar, ^"position", avatarPosition, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	create_tween().tween_property($%AspectAvatar, ^"self_modulate", Color.WHITE, 0.3).set_ease(Tween.EASE_OUT)

	currentAnimationTimer = get_tree().create_timer(0.2)
	await currentAnimationTimer.timeout
	create_tween().tween_property($%AspectName, ^"position", namePosition, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	create_tween().tween_property($%AspectName, ^"self_modulate", Color.WHITE, 0.3).set_ease(Tween.EASE_OUT)

	currentAnimationTimer = get_tree().create_timer(0.1)
	await currentAnimationTimer.timeout
	create_tween().tween_property($%AspectTitle, ^"position", titlePosition, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	create_tween().tween_property($%AspectTitle, ^"self_modulate", Color.WHITE, 0.3).set_ease(Tween.EASE_OUT)

	generatePerks()

	if not skippingText:
		await get_tree().create_timer(0.1).timeout
	var line: String = getLyraLines().pick_random()
	for i in line:
		$%AspectText.text += i
		if skippingText:
			continue
		var waitTime := 0.03
		if i == '\n':
			waitTime = 0.5
		elif i == '.' or i == '!' or i == '?':
			waitTime = 0.1
		await get_tree().create_timer(waitTime).timeout

func generatePerks() -> void:
	var perksToShow := 3

	var allAvailablePerks := PerkLibrary.Available
	var availablePerks := getPerksForRarity(allAvailablePerks, Perk.Rarity.Common)
	if availablePerks.size() < perksToShow or randf() <= 0.7:
		availablePerks = getPerksForRarity(allAvailablePerks, Perk.Rarity.Rare)
		if availablePerks.size() < perksToShow or randf() <= 0.7:
			availablePerks = getPerksForRarity(allAvailablePerks, Perk.Rarity.Epic)
			if availablePerks.size() < perksToShow or randf() <= 0.7:
				availablePerks = getPerksForRarity(allAvailablePerks, Perk.Rarity.Legendary)

	if availablePerks.size() == 0:
		MessageLog.PrintMessage("Unable to generate any perks at all :(")
		$PerksUI.visible = false
		return

	availablePerks.shuffle()

	var perksToOffer: Array[Perk.Definition]
	for i in range(3):
		if availablePerks.size() == 0:
			continue
		var perk: Perk.Definition = availablePerks.pop_front()
		perksToOffer.append(perk)

	perksToOffer.sort_custom(func(a: Perk.Definition, b: Perk.Definition) -> bool:
		return a.perkName.naturalcasecmp_to(b.perkName) < 0
	)
	for perk: Perk.Definition in perksToOffer:
		perkSelectionContainer.AddPerk(perk)

func getPerksForRarity(availablePerks: Array[Perk.Definition], maxRarity: Perk.Rarity) -> Array[Perk.Definition]:
	return availablePerks.filter(func(perk: Perk.Definition) -> bool:
		return perk.rarity <= maxRarity
	)

static var greetingShown := false

func getLyraLines() -> Array[String]:
	if not greetingShown:
		greetingShown = true
		return ["Oh, hello there! I don't believe we've met. I'm Lyra, nice to meet you!\nWhat is it going to be? Claws or fire?"]

	return [
		"After all, why not? Why wouldn't I give myself a blessing?",
		"This place is strangely empty, don't you think?",
		"Have you seen Rue anywhere? I hope she's not up to more mischief again.",
		"These windy elementals are quite annoying. Hard to fly in such stormy weather!"
	]
