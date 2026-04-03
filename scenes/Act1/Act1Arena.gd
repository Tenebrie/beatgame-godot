@tool
extends Node3D

@onready var actGenerator: ActGenerator = $ActGenerator

func _ready() -> void:
	var beatmap: Beatmap = ResourceLoader.load("res://scenes/Act1/Act1Beatmap.tres")

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
	SignalBus.OnFlushAllTimers.emit()

	if Engine.is_editor_hint():
		return
	BeatmapLoader.Load(beatmap)

	for i in range(512):
		Trigger.BasicAttack().Delay(i)

	($MainCamera as MainCamera).SetCameraMode(MainCamera.Mode.ForceFollowPlayer)

	SignalBus.OnFightBegin.emit()
