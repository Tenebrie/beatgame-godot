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
	var beatmap: Beatmap = beatmaps[0]

	var args := DanceFloor.InitArgs.new()
	args.gridSize = beatmap.gridSize
	$DanceFloor.Setup(args)

	BeatmapLoader.LoadAudio(beatmap)
	BeatmapLoader.LoadInitial(beatmap)
	var firstChunk := actGenerator.GeneratePath(Vector2i(3, 1))
	if not Engine.is_editor_hint():
		firstChunk.onCleared.connect(func() -> void:
			MessageLog.PrintMessage("The way forward is now open!")
			GlobalContext.GetPlayer().RefillStamina()
			AudioSystem.StopSongAtBreakpoint()
			SignalBus.clearTimersBefore.emit(99999)

			var secondPerkSelector := Asset.Instantiate(InteractablePerk) as InteractablePerk
			secondPerkSelector.position = Vector3(firstChunk.endPoint.x, 0, firstChunk.endPoint.y)
			$DanceFloor.add_child(secondPerkSelector)
			secondPerkSelector.perkSelected.connect(func() -> void:
				BeatmapLoader.LoadAudio(beatmaps[1])
				AudioSystem.Start()
				for i in range(512):
					Trigger.BasicAttack().Delay(i)

				var secondChunk := actGenerator.GeneratePath(firstChunk.endPoint)
				secondChunk.onCleared.connect(func() -> void:
					MessageLog.PrintMessage("The way forward is now open!")
					GlobalContext.GetPlayer().RefillStamina()
					var thirdChunk := actGenerator.GeneratePath(secondChunk.endPoint)
					thirdChunk.onCleared.connect(func() -> void:
						MessageLog.PrintMessage("Act 1 cleared, now get to the exit!")
						GlobalContext.GetPlayer().RefillStamina()
						actGenerator.GenerateExit(thirdChunk.endPoint)
					)
				)
			)

		)
	Pattern.SingleIndexed(Vector2i(4, 1)).DestroyTile()
	SignalBus.OnFlushAllTimers.emit()

	var perkSelector := Asset.Instantiate(InteractablePerk) as InteractablePerk
	perkSelector.position = Vector3(3, 0, 1)
	$DanceFloor.add_child(perkSelector)
	perkSelector.perkSelected.connect(func() -> void:
		Pattern.SingleIndexed(Vector2i(4, 1)).RestoreTile()
		SignalBus.OnFightBegin.emit()
	)

	if Engine.is_editor_hint():
		return
	BeatmapLoader.Load(beatmap)

	for i in range(512):
		Trigger.BasicAttack().Delay(i)

	($MainCamera as MainCamera).SetCameraMode(MainCamera.Mode.ForceFollowPlayer)
