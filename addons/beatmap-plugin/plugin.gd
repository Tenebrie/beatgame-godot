@tool
extends EditorPlugin

var _inspector_plugin: BeatmapInspector

func _enter_tree() -> void:
	_inspector_plugin = BeatmapInspector.new()
	_inspector_plugin.undoRedo = get_undo_redo()
	add_inspector_plugin(_inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
	_inspector_plugin = null
