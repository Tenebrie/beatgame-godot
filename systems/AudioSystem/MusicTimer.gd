class_name MusicTimer extends Node

signal timeout(triggerBeat: float)

var triggerBeat: float = INF
var boundToBeat: float = INF

var selfDestruct: bool

func _ready() -> void:
	SignalBus.clearTimersBefore.connect(on_clear_timers_before)
	SignalBus.OnFlushAllTimers.connect(on_flush_all_timers)

func start(trigger_beat: float, duration: float = 0.0) -> void:
	triggerBeat = trigger_beat
	boundToBeat = trigger_beat + duration
	selfDestruct = true
	AudioSystem.RegisterOneShotTimer(self)

func start_repeatable(trigger_beat: float) -> void:
	triggerBeat = trigger_beat
	boundToBeat = trigger_beat
	selfDestruct = false
	AudioSystem.RegisterRepeatableTimer(self)

func stop() -> void:
	triggerBeat = INF
	boundToBeat = INF
	if selfDestruct:
		queue_free()

func on_flush_all_timers() -> void:
	trigger()

func on_clear_timers_before(target_beat: float) -> void:
	if boundToBeat < target_beat && selfDestruct:
		triggerBeat = INF
		boundToBeat = INF
		queue_free()

func move_trigger(beats: float) -> void:
	triggerBeat += beats
	boundToBeat += beats

func trigger() -> void:
	var previousTriggerBeat := triggerBeat
	triggerBeat = INF
	boundToBeat = INF
	timeout.emit(previousTriggerBeat)
	if selfDestruct:
		queue_free()

func is_passed() -> bool:
	var currentTime: float = roundf(AudioSystem.get_current_beat() * 8.0) / 8.0
	return currentTime >= triggerBeat

static func Create() -> MusicTimer:
	var timer := MusicTimer.new()
	return timer
