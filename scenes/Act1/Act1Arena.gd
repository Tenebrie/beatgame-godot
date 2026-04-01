@tool
extends Node3D

func _ready() -> void:
	var beatmap: Beatmap = ResourceLoader.load("res://scenes/Act1/Act1Beatmap.tres")

	var args := DanceFloor.InitArgs.new()
	args.gridSize = beatmap.gridSize
	$DanceFloor.Setup(args)

	BeatmapLoader.LoadAudio(beatmap)
	BeatmapLoader.LoadInitial(beatmap)
	SignalBus.OnFlushAllTimers.emit()

	if Engine.is_editor_hint():
		return
	BeatmapLoader.Load(beatmap)

	for i in range(64):
		Trigger.BasicAttack().Delay(i)

	($MainCamera as MainCamera).SetCameraMode(MainCamera.Mode.ForceFollowPlayer)

	SignalBus.OnFightBegin.emit()
