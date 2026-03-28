extends Node3D

func _ready() -> void:
	var beatmap: Beatmap = ResourceLoader.load("res://scenes/TutorialArenaBeatmap.tres")

	var args := DanceFloor.InitArgs.new()
	args.gridSize = beatmap.gridSize
	$DanceFloor.Setup(args)

	#Pattern.Rect("a1", "b2").DestroyTile()
	#Pattern.Rect("d1", "d2").DestroyTile()
	BeatmapLoader.LoadInitial(beatmap)
	SignalBus.OnFlushAllTimers.emit()
	BeatmapLoader.Load(beatmap)
	AudioSystem.SortTimers()

	SignalBus.OnFightBegin.emit()
