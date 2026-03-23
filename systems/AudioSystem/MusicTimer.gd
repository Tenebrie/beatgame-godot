class_name MusicTimer extends Node

signal timeout(triggerBeat: int)

var triggerBeat: float = INF
var selfDestruct: bool
	
func start(trigger_beat: float) -> void:
	triggerBeat = trigger_beat
	selfDestruct = true
	
func start_repeatable(trigger_beat: float) -> void:
	triggerBeat = trigger_beat
	selfDestruct = false

func _process(_delta: float) -> void:
	var currentTime: float = roundf(AudioSystem.get_current_beat() * 8.0) / 8.0
	if currentTime >= triggerBeat:
		var previousTriggerBeat := triggerBeat
		triggerBeat = INF
		timeout.emit(previousTriggerBeat)
		if selfDestruct:
			queue_free()

func is_passed() -> bool:
	var currentTime: float = roundf(AudioSystem.get_current_beat() * 8.0) / 8.0
	return currentTime >= triggerBeat
