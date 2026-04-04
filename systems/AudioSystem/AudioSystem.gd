@tool
extends Node

var beatmap: Beatmap
var isTimerOrderDirty := false

var audioBus: AudioBus
var fadeOutReverbEffect: AudioEffectReverb

func _ready() -> void:
	SignalBus.OnFightBegin.connect(func() -> void:
		Start()
	)
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
	if not Engine.is_editor_hint():
		audioBus = AudioBus.new()
		add_child(audioBus)
		fadeOutReverbEffect = AudioEffectReverb.new()
		fadeOutReverbEffect.dry = 1
		fadeOutReverbEffect.wet = 0
		fadeOutReverbEffect.damping = 1
		fadeOutReverbEffect.room_size = 0.6
		audioBus.addEffect(fadeOutReverbEffect)

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

var fadeOutTween: Tween

func Start() -> void:
	$AudioAgent.StartPlaying()
	if fadeOutTween:
		fadeOutTween.kill()
	fadeOutReverbEffect.dry = 1.0
	fadeOutReverbEffect.wet = 0.0
	$AudioAgent.GetAudioPlayer().volume_linear = 0.7

var breakpointTimer: MusicTimer
func WaitForBreakpoint() -> void:
	if breakpointTimer and not breakpointTimer.is_passed():
		await breakpointTimer.timeout

func StopSongAtBreakpoint() -> void:
	var audioAgent: AudioAgent = $AudioAgent
	var timer := MusicTimer.Create()
	var currentBeat := get_current_beat()
	var nextBreakpoint := (floorf(currentBeat / 16.0) + 1) * 16.0
	if nextBreakpoint - currentBeat < 2.0:
		nextBreakpoint += 8.0
	var beatDiff := nextBreakpoint - currentBeat
	var secondsDiff := beatDiff * 60.0 / get_current_bpm()
	var player := audioAgent.GetAudioPlayer()
	fadeOutTween = create_tween()
	fadeOutTween.set_parallel()
	fadeOutTween.tween_property(fadeOutReverbEffect, ^"dry", 0, secondsDiff)
	fadeOutTween.tween_property(fadeOutReverbEffect, ^"wet", 0.5, secondsDiff)
	fadeOutTween.tween_property(player, ^"volume_linear", 0.0, secondsDiff)
	breakpointTimer = timer
	timer.start(nextBreakpoint)
	timer.timeout.connect(func(_beat: float) -> void:
		$AudioAgent.StopPlaying()
		SignalBus.ArenaReset.emit()
	)

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
			SignalBus.AfterAnyBeat.emit(currentTime)
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
