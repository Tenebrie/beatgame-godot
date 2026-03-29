@tool
class_name BeatmapEditor extends VBoxContainer

signal ValidationErrorFixed

var resource: Beatmap
var _buttons: Dictionary = {}  # Vector2i -> Button

func setup(res: Beatmap) -> void:
	resource = res
	resource.changed.connect(_rebuild)
	resource.stateUpdated.connect(func() -> void:
		var errorCount := _validateResource()
		ResourceSaver.save(resource)
		if errorCount > 0:
			ValidationErrorFixed.emit()
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
		var previousPattern: BeatmapPatternData
		var selector := str(Pattern.letters[x]) + str(y + 1)
		var debugPos := "[%s/%d-%d]"%[selector, x, y]

		for pattern: BeatmapPatternData in value:
			var clampedFinishedAt := minf(pattern.finishedAt, resource.audioFile.get_length())
			if pattern.startedAt < 0.0:
				print("FIX %s: Removing %s as it has started before time 0"%[debugPos, pattern])
				errorCount += 1
				value.remove_at(value.find(pattern))
			elif clampedFinishedAt - pattern.startedAt == 0.0:
				print("FIX %s: Removing %s as it has length 0"%[debugPos, pattern])
				errorCount += 1
				value.remove_at(value.find(pattern))
			elif previousPattern and pattern.state == previousPattern.state and pattern.startedAt == previousPattern.finishedAt:
				print("FIX %s: Merging %s with %s as they have the same state"%[debugPos, previousPattern, pattern])
				errorCount += 1
				value.remove_at(value.find(pattern))
				previousPattern.finishedAt = pattern.finishedAt
				previousPattern = pattern
			#elif previousPattern and previousPattern.finishedAt < pattern.startedAt:
				#print("FIX %s: Setting %s's finishedAt to %s's startedAt to close the gap"%[debugPos, previousPattern, pattern])
				#errorCount += 1
				#previousPattern.finishedAt = pattern.startedAt
				#previousPattern = pattern
			elif previousPattern and previousPattern.finishedAt > pattern.startedAt:
				print("FIX %s: Setting %s's finishedAt to %s's startedAt to prevent overlapping"%[debugPos, previousPattern, pattern])
				errorCount += 1
				previousPattern.finishedAt = pattern.startedAt
				previousPattern = pattern
			else:
				previousPattern = pattern


	#if errorCount > 0:
		#print("Found " + str(errorCount) + " errors during validation.")
	return errorCount

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	var controls: BeatmapInspectorWidget = preload("res://addons/beatmap-plugin/BeatmapInspectorWidget.tscn").instantiate()
	controls.Setup(resource, self)
	add_child(controls)
