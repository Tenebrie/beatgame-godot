extends Node

var isFightTriggered := false

func _ready() -> void:
	var args := DanceFloor.InitArgs.new()
	args.gridSize = Vector2i(32, 4)
	args.showLabels = true
	$DanceFloor.Setup(args)
	$DanceFloor/Boss.set_grid_size(Vector2i(4, 4))

	GlobalContext.GetBoss().prep_patterns()
	SignalBus.OnFlushAllTimers.emit()

	GlobalContext.GetBoss().queue_patterns()
	AudioSystem.SortTimers()
	print("Maximum theoretical boss damage: " + str(Stats.CalculateOptimalDamage()))

	SignalBus.OnPlayerMove.connect(_trigger_fight)
	SignalBus.ArenaReset.connect(_on_arena_reset)

func _trigger_fight(gridPos: Vector2i, _oldPos: Vector2i) -> void:
	if isFightTriggered or gridPos.x < 4:
		return

	isFightTriggered = true
	GlobalContext.GetAudioAgent().StartPlaying()
	SignalBus.OnFightBegin.emit()

func _on_arena_reset() -> void:
	isFightTriggered = false
