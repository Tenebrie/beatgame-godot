class_name BeatmapInspector extends EditorInspectorPlugin

var undoRedo: EditorUndoRedoManager

func _can_handle(object: Object) -> bool:
	return object is Beatmap

func _parse_begin(object: Object) -> void:
	var editor = BeatmapEditor.new()
	editor.setup(object as Beatmap, undoRedo)
	add_custom_control(editor)
