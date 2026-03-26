class_name DifficultyPicker extends CanvasLayer

func _ready() -> void:
	SignalBus.OnFightBegin.connect(_on_fight_begin)
	var group := ButtonGroup.new()
	var practiceCheckbox := $Panel/MarginContainer/VBoxContainer/PracticeDifficulty/HBoxContainer/DifficultyCheckbox
	var normalCheckbox := $Panel/MarginContainer/VBoxContainer/NormalDifficulty/HBoxContainer/DifficultyCheckbox
	var harderCheckbox := $Panel/MarginContainer/VBoxContainer/HarderDifficulty/HBoxContainer/DifficultyCheckbox
	var extraHardCheckbox := $Panel/MarginContainer/VBoxContainer/ExtraHardDifficulty/HBoxContainer/DifficultyCheckbox
	practiceCheckbox.button_group = group
	normalCheckbox.button_group = group
	harderCheckbox.button_group = group
	extraHardCheckbox.button_group = group
	group.pressed.connect(func(button: BaseButton) -> void:
		if button == practiceCheckbox:
			difficulty = 0
		if button == normalCheckbox:
			difficulty = 1
		if button == harderCheckbox:
			difficulty = 2
		if button == extraHardCheckbox:
			difficulty = 3
		Achievements.SaveValue("preferred_difficulty", difficulty)
	)
	
	var preferredDifficulty: int = Achievements.LoadValue("preferred_difficulty", 1)
	if preferredDifficulty == 0:
		practiceCheckbox.button_pressed = true
	elif preferredDifficulty == 1:
		normalCheckbox.button_pressed = true
	elif preferredDifficulty == 2:
		harderCheckbox.button_pressed = true
	elif preferredDifficulty == 3:
		extraHardCheckbox.button_pressed = true
	#normalCheckbox.button_pressed = true
	
	var harderUnlocked: bool = Achievements.LoadValue("harder_unlocked", false)
	var extraHardUnlocked: bool = Achievements.LoadValue("extra_hard_unlocked", false)
	if not harderUnlocked:
		harderCheckbox.disabled = true
	if not extraHardUnlocked:
		extraHardCheckbox.disabled = true

var difficulty := 1
static var LastPlayedDifficulty := 1

func _on_fight_begin() -> void:
	var player := GlobalContext.GetPlayer()
	var boss := GlobalContext.GetBoss()
	if difficulty == 0:
		print("Starting at Practice difficulty")
		boss.SetMaximumHealth(500.0)
		player.SetMaximumHealth(5.0)
		player.SetRegeneration(1.0 / 16.0)
		player.MakeImmortal()
	elif difficulty == 1:
		print("Starting at Normal difficulty")
		boss.SetMaximumHealth(500.0)
		player.SetMaximumHealth(5.0)
		player.SetRegeneration(1.0 / 16.0)
	elif difficulty == 2:
		print("Starting at Harder difficulty")
		boss.SetMaximumHealth(550.0)
		player.SetMaximumHealth(4.0)
		player.SetRegeneration(1.0 / 16.0)
	elif difficulty == 3:
		print("Starting at Extra Hard difficulty")
		boss.SetMaximumHealth(600.0)
		player.SetMaximumHealth(4.0)
		player.SetRegeneration(0.0)
	
	LastPlayedDifficulty = difficulty
	queue_free()
