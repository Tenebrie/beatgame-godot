class_name Trigger extends Node

var triggerTimer: MusicTimer

signal resolved

func _init() -> void:
	name = "Trigger"
	var danceFloor := GlobalContext.GetDanceFloor()
	triggerTimer = MusicTimer.Create()
	triggerTimer.start(Pattern.BuilderTime)
	triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			resolved.emit()
	)
		
func Delay(delay: float) -> Trigger:
	triggerTimer.move_trigger(delay)
	return self
	
static func BasicAttack() -> Trigger:
	var trigger := new()
	trigger.triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			SignalBus.OnBasicBeat.emit()
	)
	return trigger
	
static func EnemyMove(row: float) -> Trigger:
	var trigger := new()
	trigger.triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			GlobalContext.GetBoss().move_to_row_right(row)
	)
	return trigger

static func EnemyMoveToPlayerRow() -> Trigger:
	var trigger := new()
	trigger.triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			var playerRow := GlobalContext.GetPlayer().grid_pos.y + 1
			GlobalContext.GetBoss().move_to_row_right(playerRow)
	)
	return trigger
	
func Done() -> void:
	await resolved
