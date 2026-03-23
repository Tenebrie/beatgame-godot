extends Node

var _scene_cache: Dictionary = {}

func _ready() -> void:
	var file := FileAccess.open("res://scene_cache.json", FileAccess.READ)
	_scene_cache = JSON.parse_string(file.get_as_text())

func Instantiate(type: GDScript) -> Node:
	var sceneName := type.get_global_name()
	assert(_scene_cache.has(sceneName), "No scene found: " + sceneName)
	return (load(_scene_cache[sceneName]) as PackedScene).instantiate()
