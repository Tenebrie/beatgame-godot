extends Node

func _ready() -> void:
	SignalBus.OnPlayerDeath.connect(_on_player_death)
	SignalBus.OnAdversaryDeath.connect(_on_adversary_death)

func _on_player_death() -> void:
	var defeatScreen := Asset.Instantiate(DefeatScreen)
	add_child(defeatScreen)
	var audioAgent := GlobalContext.GetAudioAgent().find_child(^"AudioStreamPlayer")
	create_tween().tween_property(audioAgent, ^"pitch_scale", 0.001, 1.0)
	create_tween().tween_property(audioAgent, ^"volume_linear", 0.5, 1.0)
	await get_tree().create_timer(1.0).timeout
	GlobalContext.GetAudioAgent().StopPlaying()

func _on_adversary_death() -> void:
	var victoryScreen := Asset.Instantiate(VictoryScreen)
	add_child(victoryScreen)
	var audioAgent := GlobalContext.GetAudioAgent().find_child(^"AudioStreamPlayer")
	create_tween().tween_property(audioAgent, ^"pitch_scale", 0.001, 1.0)
	create_tween().tween_property(audioAgent, ^"volume_linear", 0.5, 1.0)
	await get_tree().create_timer(1.0).timeout
	GlobalContext.GetAudioAgent().StopPlaying()

func Restart() -> void:
	SignalBus.ArenaReset.emit()
	await get_tree().create_timer(0.0).timeout
	Pattern.ResetState()
	Stats.ResetState()
	get_tree().reload_current_scene()
