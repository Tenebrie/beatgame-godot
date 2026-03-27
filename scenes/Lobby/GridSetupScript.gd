@tool
extends Node

func _ready() -> void:
	var danceFloor: DanceFloor = get_parent().find_child("DanceFloor")
	if danceFloor == null:
		return

	var args := DanceFloor.InitArgs.new()
	args.gridSize = Vector2i(4, 4)
	danceFloor.Setup(args)
