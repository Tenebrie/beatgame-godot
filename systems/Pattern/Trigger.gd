class_name Trigger extends Node

var triggerTimer: MusicTimer
var boundToNode: bool
var boundNode: Node

signal onResolve
signal resolved

func _init() -> void:
	name = "Trigger"
	triggerTimer = MusicTimer.Create()
	triggerTimer.start(Pattern.BuilderTime)
	triggerTimer.timeout.connect(
		func(_beat: int) -> void:
			if boundToNode:
				if not boundNode or not is_instance_valid(boundNode):
					return
				if boundNode is Dancer and not boundNode.isAlive:
					return
			onResolve.emit()
			resolved.emit()
	)

func Delay(delay: float) -> Trigger:
	triggerTimer.move_trigger(delay)
	return self

func BindTo(node: Node) -> Trigger:
	boundToNode = true
	boundNode = node
	return self

static func BasicAttack() -> Trigger:
	var trigger := new()
	trigger.onResolve.connect(
		func() -> void:
			SignalBus.OnBasicBeat.emit()
	)
	Stats.RecordBasicAttackTrigger()
	return trigger

static func Execute(callback: Callable) -> Trigger:
	var trigger := new()
	trigger.onResolve.connect(
		func() -> void:
			callback.call()
	)
	return trigger

static func EnemyMoveToColumnTop(column: String) -> Trigger:
	var columnIndex := Pattern.letters.find(column)
	var builderOffset := Pattern.BuilderOffset
	var trigger := new()
	trigger.onResolve.connect(
		func() -> void:
			GlobalContext.GetBoss().move_to_column_top(columnIndex + builderOffset.x)
	)
	return trigger

static func EnemyMove(pos: Vector2) -> Trigger:
	var trigger := new()
	var builderOffset := Pattern.BuilderOffset
	trigger.onResolve.connect(
		func() -> void:
			GlobalContext.GetBoss().move_to(Vector2(pos.x + builderOffset.x, pos.y + builderOffset.y))
	)
	return trigger

static func EnemyMoveToRowLeft(row: float) -> Trigger:
	var trigger := new()
	var builderOffset := Pattern.BuilderOffset
	trigger.onResolve.connect(
		func() -> void:
			GlobalContext.GetBoss().move_to_row_left(row + builderOffset.y)
	)
	return trigger

static func EnemyMoveToRowRight(row: float) -> Trigger:
	var trigger := new()
	var builderOffset := Pattern.BuilderOffset
	trigger.onResolve.connect(
		func() -> void:
			GlobalContext.GetBoss().move_to_row_right(row + builderOffset.y)
	)
	return trigger

static func EnemyMoveToPlayerRow() -> Trigger:
	var trigger := new()
	trigger.onResolve.connect(
		func() -> void:
			var playerRow := GlobalContext.GetPlayer().GridPosition.y + 1
			GlobalContext.GetBoss().move_to_row_right(playerRow)
	)
	return trigger

func Done() -> void:
	await resolved
