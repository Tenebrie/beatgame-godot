extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player := GlobalContext.GetPlayer()
	var hpPercent := 1.0 - player.damageTaken / player.maximumHealth
	var displayPercent: float = pow(hpPercent, 1.5) * 100.0
	$PanelContainer/Control/ProgressBar.value = displayPercent
