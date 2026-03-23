extends Node

func get_current_beat() -> float:
	return GlobalContext.GetAudioAgent().get_position_beats()

func get_current_bpm() -> float:
	return GlobalContext.GetAudioAgent().get_bpm()
	
func fast_forward(beats: float) -> void:
	GlobalContext.GetAudioAgent().fast_forward(beats)
	
func set_playback_speed(speed: float) -> void:
	GlobalContext.GetAudioAgent().set_speed(speed)
	if speed != 1.0:
		GlobalContext.GetAudioAgent().set_volume(0.2)
	else:
		GlobalContext.GetAudioAgent().set_volume(1.0)
