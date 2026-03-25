class_name Trigger extends Node

var triggerTimer: MusicTimer

signal resolved

func _init() -> void:
	name = "Trigger"
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
	
static func Execute(callback: Callable) -> Trigger:
	var trigger := new()
	trigger.triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			callback.call()
	)
	return trigger
	
static func EnemyMoveToColumnTop(column: String) -> Trigger:
	var columnIndex := Pattern.letters.find(column)
	var trigger := new()
	trigger.triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			GlobalContext.GetBoss().move_to_column_top(columnIndex)
	)
	return trigger
	
static func EnemyMove(pos: Vector2) -> Trigger:
	var trigger := new()
	trigger.triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			GlobalContext.GetBoss().move_to(pos)
	)
	return trigger

static func EnemyMoveToRowLeft(row: float) -> Trigger:
	var trigger := new()
	trigger.triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			GlobalContext.GetBoss().move_to_row_left(row)
	)
	return trigger

static func EnemyMoveToRowRight(row: float) -> Trigger:
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
