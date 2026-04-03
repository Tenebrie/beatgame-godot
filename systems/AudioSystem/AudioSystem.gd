@tool
extends Node

var beatmap: Beatmap
var isTimerOrderDirty := false

func _ready() -> void:
	SignalBus.ArenaReset.connect(func() -> void:
		nextEmittedBeat = 0.0
		nextEmittedMajorBeat = 0.0
		nextEmittedMinorBeat = 1.0
		$AudioAgent.Reset()
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
	return $AudioAgent.get_position_beats()

func get_current_bpm() -> float:
	return $AudioAgent.get_bpm()

func fast_forward(beats: float) -> void:
	$AudioAgent.fast_forward(beats)

func set_playback_speed(speed: float) -> void:
	var audioAgent: AudioAgent = $AudioAgent
	audioAgent.set_speed(speed)
	if speed != 1.0:
		audioAgent.set_volume(0.2)
	else:
		audioAgent.set_volume(1.0)

func RegisterBeatmap(newBeatmap: Beatmap) -> void:
	beatmap = newBeatmap
	$AudioAgent.Reset()

func IsSongStarted() -> bool:
	return $AudioAgent.IsPlaying()

func Start() -> void:
	$AudioAgent.StartPlaying()

func StopSongAtBreakpoint() -> void:
	$AudioAgent.StopPlaying()
	nextEmittedBeat = 0.0
	nextEmittedMajorBeat = 0.0
	nextEmittedMinorBeat = 1.0

func RegisterOneShotTimer(timer: MusicTimer) -> void:
	$OneShotTimers.add_child(timer)
	isTimerOrderDirty = true

func RegisterRepeatableTimer(timer: MusicTimer) -> void:
	if timer.get_parent() == null:
		$RepeatableTimers.add_child(timer)

func sortTimers() -> void:
	var children := $OneShotTimers.get_children()
	children.sort_custom(func(a: MusicTimer, b: MusicTimer) -> bool:
		return a.triggerBeat < b.triggerBeat
	)
	for i in range(children.size()):
		$OneShotTimers.move_child(children[i], i)

var nextEmittedBeat := 0.0
var nextEmittedMajorBeat := 0.0
var nextEmittedMinorBeat := 1.0

func _process(_delta: float) -> void:
	var audioAgent: AudioAgent = $AudioAgent

	var currentTime: float = roundf(audioAgent.get_position_beats() * 8.0) / 8.0

	if audioAgent.IsPlaying():
		if currentTime >= nextEmittedBeat:
			SignalBus.OnAnyBeat.emit(currentTime)
			nextEmittedBeat = currentTime + 1.0 / 8.0
		if currentTime >= nextEmittedMajorBeat:
			SignalBus.OnMajorBeat.emit(currentTime)
			SignalBus.OnFullBeat.emit(currentTime)
			nextEmittedMajorBeat = floorf(currentTime) + 2.0
		if currentTime >= nextEmittedMinorBeat:
			SignalBus.OnMinorBeat.emit(currentTime)
			SignalBus.OnFullBeat.emit(currentTime)
			nextEmittedMinorBeat = floorf(currentTime) + 2.0

	if isTimerOrderDirty:
		sortTimers()
		isTimerOrderDirty = false

	for timer in $RepeatableTimers.get_children():
		if currentTime >= timer.triggerBeat:
			timer.trigger()

	for timer in $OneShotTimers.get_children():
		if currentTime >= timer.triggerBeat:
			timer.trigger()
		else:
			return
