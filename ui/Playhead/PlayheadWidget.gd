extends Control


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	var pos := GlobalContext.GetAudioAgent().get_position_seconds()
	var dur := GlobalContext.GetAudioAgent().get_duration_seconds()
	var beat := GlobalContext.GetAudioAgent().get_position_beats()
	$ProgressBar/TimeLabel.text = formatTime(pos) + " / " + formatTime(dur)
	$ProgressBar/BeatLabel.text = str(floori(beat + 1))
	$ProgressBar.value = pos / dur * 100.0

func formatTime(time: float) -> String:
	var minutes := floori(time / 60.0)
	var seconds := floori(time - minutes * 60.0)
	var minutesPadded := "0" + str(minutes) if minutes < 10 else str(minutes)
	var secondsPadded := "0" + str(seconds) if seconds < 10 else str(seconds)
	return minutesPadded + ":" + secondsPadded
