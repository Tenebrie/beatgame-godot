@tool
class_name BeatmapEditor extends VBoxContainer

var resource: Beatmap
var _buttons: Dictionary = {}  # Vector2i -> Button

func setup(res: Beatmap) -> void:
	resource = res
	resource.changed.connect(_rebuild)
	resource.stateUpdated.connect(func() -> void:
		var errorCount := _validateResource()
		ResourceSaver.save(resource)
		if errorCount > 0:
			_rebuild()
	)
	var inspector := EditorInterface.get_inspector()
	inspector.property_edited.connect(func(property: String) -> void:
		_rebuild()
	)
	_rebuild()

func _validateResource() -> int:
	var errorCount := 0
	for key: String in resource.patterns.keys():
		var x = int(key.split("-")[0])
		var y = int(key.split("-")[1])
		if x >= resource.gridSize.x:
			print("WARN: x value is beyond the grid size: " + str(x) + "/" + str(resource.gridSize.x))
			resource.patterns.erase(key)
			errorCount += 1
			continue

		if y >= resource.gridSize.y:
			print("WARN: y value is beyond the grid size: " + str(y) + "/" + str(resource.gridSize.y))
			resource.patterns.erase(key)
			errorCount += 1
			continue

		var value = resource.patterns[key]
		for pattern: BeatmapPatternData in value:
			if pattern.startedAt < 0.0:
				print("WARN: Found pattern starting before time 0")
				errorCount += 1
				value.remove_at(value.find(pattern))
			var clampedFinishedAt := minf(pattern.finishedAt, resource.audioFile.get_length())
			if clampedFinishedAt - pattern.startedAt == 0.0:
				print("WARN: Found pattern with length 0")
				errorCount += 1
				value.remove_at(value.find(pattern))

	if errorCount > 0:
		print("Found " + str(errorCount) + " errors during validation.")
	return errorCount

func _rebuild() -> void:
	print("Rebuild")
	for child in get_children():
		child.queue_free()
	var controls := preload("res://addons/beatmap-plugin/BeatmapInspectorWidget.tscn").instantiate()
	controls.Setup(resource)
	add_child(controls)
