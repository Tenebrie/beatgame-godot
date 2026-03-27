extends Node3D

func _ready() -> void:
	var args := DanceFloor.InitArgs.new()
	args.gridSize = Vector2i(4, 4)
	$DanceFloor.Setup(args)

	Pattern.Rect("a1", "b2").DestroyTile()
	Pattern.Rect("d1", "d2").DestroyTile()
	SignalBus.OnFlushAllTimers.emit()
