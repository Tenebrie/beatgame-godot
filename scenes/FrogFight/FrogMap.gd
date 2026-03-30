extends Node3D

func _ready() -> void:
	var beatmap: Beatmap = ResourceLoader.load("res://scenes/FrogFight/FrogFightBeatmap.tres")

	var args := DanceFloor.InitArgs.new()
	args.gridSize = beatmap.gridSize
	$DanceFloor.Setup(args)

	BeatmapLoader.LoadAudio(beatmap)
	BeatmapLoader.LoadInitial(beatmap)
	SignalBus.OnFlushAllTimers.emit()
	BeatmapLoader.Load(beatmap)
	AudioSystem.SortTimers()

	SignalBus.OnFightBegin.emit()
