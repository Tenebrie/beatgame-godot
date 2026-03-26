extends Control

func _ready() -> void:
	modulate = Color.from_hsv(0, 0, 1, 0.0)
	SignalBus.OnFightBegin.connect(_on_fight_begin)
	
func _on_fight_begin() -> void:
	create_tween().tween_property(self, ^"modulate", Color.from_hsv(0, 0, 1, 1.0), 1.0)

var isInOverdrive := false

func _process(delta: float) -> void:
	var boss := GlobalContext.GetBoss()
	if not isInOverdrive:
		$PanelContainer/Control/ProgressBar.value = (1.0 - boss.damageTaken / boss.maximumHealth) * 100.0
		
	if not isInOverdrive and boss.damageTaken >= boss.maximumHealth:
		isInOverdrive = true
		var styleBox: StyleBoxFlat = $PanelContainer/Control/ProgressBar.get_theme_stylebox("fill").duplicate()
		styleBox.bg_color = Color.DARK_ORANGE
		$PanelContainer/Control/ProgressBar.add_theme_stylebox_override("fill", styleBox)
		$PanelContainer/Control/ProgressBar.value = 100.0
		
	if isInOverdrive:
		var overdrive := boss.damageTaken - boss.maximumHealth
		$PanelContainer/Control/ProgressBar/OverdriveLabel.text = "Score +" + str(roundi(overdrive))
