extends Node3D

func _ready() -> void:
	var beatmap: Beatmap = ResourceLoader.load("res://scenes/Lobby/LobbyMapGridSetup.tres")

	var args := DanceFloor.InitArgs.new()
	args.gridSize = beatmap.gridSize
	$DanceFloor.Setup(args)

	BeatmapLoader.LoadAudio(beatmap)
	BeatmapLoader.LoadInitial(beatmap)
	SignalBus.OnFlushAllTimers.emit()
	BeatmapLoader.Load(beatmap)

	#SignalBus.OnFightBegin.emit()

	SignalBus.OnPlayerMove.connect(func(to: Vector2i, _from: Vector2i) -> void:
		if to.x == 2 and to.y == 0:
			get_tree().change_scene_to_file("res://scenes/TutorialArena.tscn")
		elif to.x == 4 and to.y == 0:
			get_tree().change_scene_to_file("res://scenes/FrogFight/FrogMap.tscn")
	)
