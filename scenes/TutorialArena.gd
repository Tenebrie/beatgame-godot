extends Node

var isFightTriggered := false

func _ready() -> void:
	var beatmap: Beatmap = ResourceLoader.load("res://scenes/TutorialArenaBeatmap.tres")

	var args := DanceFloor.InitArgs.new()
	args.gridSize = beatmap.gridSize
	$DanceFloor.Setup(args)

	BeatmapLoader.LoadAudio(beatmap)
	BeatmapLoader.LoadInitial(beatmap)

	GlobalContext.GetBoss().prep_patterns()
	SignalBus.OnFlushAllTimers.emit()

	GlobalContext.GetBoss().queue_patterns()
	print("Maximum theoretical boss damage: " + str(Stats.CalculateOptimalDamage()))

	SignalBus.OnPlayerMove.connect(_trigger_fight)
	SignalBus.ArenaReset.connect(_on_arena_reset)

func _trigger_fight(gridPos: Vector2i, _oldPos: Vector2i) -> void:
	if isFightTriggered or gridPos.x < 4:
		return

	isFightTriggered = true
	SignalBus.OnFightBegin.emit()

func _on_arena_reset() -> void:
	isFightTriggered = false
