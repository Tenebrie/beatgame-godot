extends Node

var _scene_cache: Dictionary = {}

func _ready() -> void:
	_build_scene_cache("res://")

func _build_scene_cache(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir:
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		var full_path := dir_path.path_join(file)
		if dir.current_is_dir():
			_build_scene_cache(full_path)
		elif file.ends_with(".tscn"):
			var sceneName := file.get_basename()
			_scene_cache[sceneName] = full_path
		file = dir.get_next()

func Instantiate(type: GDScript) -> Node:
	var sceneName := type.get_global_name()
	assert(_scene_cache.has(sceneName), "No scene found: " + sceneName)
	return (load(_scene_cache[sceneName]) as PackedScene).instantiate()
