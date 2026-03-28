class_name TileDriver extends Node

var telegraph: float = 0.0
var telegraphSpeed: float = 0.0

func Start(_pos: Vector2i, delay: float) -> void:
	telegraphSpeed = 1.0 / delay

func _process(delta: float) -> void:
	if not AudioSystem.IsSongStarted():
		return
	var bpmMod: float = AudioSystem.get_current_bpm() / 60.0
	telegraph += delta * telegraphSpeed * bpmMod
	telegraph = min(telegraph, 1.0)
	if telegraph >= 1.0:
		queue_free()
