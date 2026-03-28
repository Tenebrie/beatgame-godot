@tool
extends EditorPlugin

var _inspector_plugin: BeatmapInspector

func _enter_tree() -> void:
	print("Work")
	_inspector_plugin = BeatmapInspector.new()
	add_inspector_plugin(_inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
	_inspector_plugin = null
