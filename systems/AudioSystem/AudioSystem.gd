extends Node

var beatmap: Beatmap

func _ready() -> void:
	SignalBus.ArenaReset.connect(func() -> void:
		while $OneShotTimers.get_child_count() > 0:
			var child := $OneShotTimers.get_child(0)
			$OneShotTimers.remove_child(child)
			child.queue_free()
		while $RepeatableTimers.get_child_count() > 0:
			var child := $RepeatableTimers.get_child(0)
			$RepeatableTimers.remove_child(child)
			child.queue_free()
	)

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

func RegisterBeatmap(newBeatmap: Beatmap) -> void:
	beatmap = newBeatmap

func IsSongStarted() -> bool:
	var audioAgent := GlobalContext.GetAudioAgent()
	if audioAgent == null:
		return false
	return audioAgent.IsPlaying()

func RegisterOneShotTimer(timer: MusicTimer) -> void:
	$OneShotTimers.add_child(timer)

func RegisterRepeatableTimer(timer: MusicTimer) -> void:
	if timer.get_parent() == null:
		$RepeatableTimers.add_child(timer)

func SortTimers() -> void:
	var children := $OneShotTimers.get_children()
	children.sort_custom(func(a: MusicTimer, b: MusicTimer) -> bool:
		return a.triggerBeat < b.triggerBeat
	)
	for i in range(children.size()):
		$OneShotTimers.move_child(children[i], i)

func _process(_delta: float) -> void:
	var audioAgent := GlobalContext.GetAudioAgent()
	if audioAgent == null:
		return

	var currentTime: float = roundf(audioAgent.get_position_beats() * 8.0) / 8.0

	for timer in $RepeatableTimers.get_children():
		if currentTime >= timer.triggerBeat:
			timer.trigger()

	for timer in $OneShotTimers.get_children():
		if currentTime >= timer.triggerBeat:
			timer.trigger()
		else:
			return
