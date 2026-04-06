@tool
extends Node3D

@onready var actGenerator: ActGenerator = $ActGenerator

func _ready() -> void:
	var beatmaps: Array[Beatmap] = [
		ResourceLoader.load("res://scenes/Act1/Act1Beatmap01.tres"),
		#ResourceLoader.load("res://scenes/Act1/Act1Beatmap02.tres"),
		ResourceLoader.load("res://scenes/Act1/Act1Beatmap03.tres"),
		ResourceLoader.load("res://scenes/Act1/Act1Beatmap04.tres")
	]
	beatmaps.shuffle()
	var beatmap: Beatmap = beatmaps.pop_front()

	var args := DanceFloor.InitArgs.new()
	args.gridSize = beatmap.gridSize
	$DanceFloor.Setup(args)

	BeatmapLoader.LoadAudio(beatmap)
	BeatmapLoader.LoadInitial(beatmap)
	CreateChunk(Vector2i(3, 1), 5, beatmaps)

	Pattern.SingleIndexed(Vector2i(4, 1)).DestroyTile()
	SignalBus.OnFlushAllTimers.emit()

	var perkSelector := Asset.Instantiate(InteractablePerk) as InteractablePerk
	perkSelector.position = Vector3(3, 0, 1)
	$DanceFloor.add_child(perkSelector)

	if Engine.is_editor_hint():
		return

	perkSelector.perkSelected.connect(func() -> void:
		Pattern.SingleIndexed(Vector2i(4, 1)).RestoreTile()
		SignalBus.OnFightBegin.emit()
		AudioSystem.onSongFinished.connect(func() -> void:
			if beatmaps.size() == 0:
				MessageLog.PrintMessage("It seems we ran out of music! That's a defeat, I guess.")
			var nextBeatmap: Beatmap = beatmaps.pop_front()
			SignalBus.ArenaReset.emit()
			BeatmapLoader.LoadAudio(nextBeatmap)
			SignalBus.OnFightBegin.emit()
			for i in range(512):
				Trigger.BasicAttack().Delay(i)
		)
	)
	BeatmapLoader.Load(beatmap)

	for i in range(512):
		Trigger.BasicAttack().Delay(i)

	($MainCamera as MainCamera).SetCameraMode(MainCamera.Mode.ForceFollowPlayer)

func CreateChunk(startPosition: Vector2i, maxDepth: int, beatmaps: Array[Beatmap], depth := 0) -> void:
	var chunk := actGenerator.GeneratePath(startPosition)
	if Engine.is_editor_hint():
		return

	chunk.onCleared.connect(func() -> void:
		MessageLog.PrintMessage("The way forward is now open!")
		GlobalContext.GetPlayer().RefillStamina()
		AudioSystem.StopSongAtBreakpoint()

		if depth + 1 < maxDepth:
			var perkSelector := Asset.Instantiate(InteractablePerk) as InteractablePerk
			perkSelector.position = Vector3(chunk.endPoint.x, 0, chunk.endPoint.y)
			$DanceFloor.add_child(perkSelector)

			perkSelector.perkSelected.connect(func() -> void:
				await AudioSystem.WaitForBreakpoint()
				GlobalContext.GetPlayer().RefillStamina()
				#BeatmapLoader.LoadAudio(beatmaps[depth + 1])
				#SignalBus.OnFightBegin.emit()
				AudioSystem.ResumeFromBreakpoint()
				#for i in range(512):
					#Trigger.BasicAttack().Delay(i)
				CreateChunk(chunk.endPoint, maxDepth, beatmaps, depth + 1)
			)
		else:
			MessageLog.PrintMessage("Act 1 cleared, now get to the exit!")
			actGenerator.GenerateExit(chunk.endPoint)
	)
