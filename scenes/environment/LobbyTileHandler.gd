extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.OnPlayerMove.connect(_on_player_move)
	
	
func _on_player_move(to: Vector2i, from: Vector2i) -> void:
	if from.x < 4:
		SignalBus.OnDestroyTile.emit(from.x, from.y)
