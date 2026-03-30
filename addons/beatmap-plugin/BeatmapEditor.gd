@tool
class_name BeatmapEditor extends VBoxContainer

signal ValidationErrorFixed
signal FixableErrorsFound(count: int)

var resource: Beatmap
var undoRedo: EditorUndoRedoManager
var _buttons: Dictionary = {}  # Vector2i -> Button

var _last_patterns_snapshot: Dictionary[String, Array]

func setup(res: Beatmap, newUndoRedo: EditorUndoRedoManager) -> void:
	resource = res
	undoRedo = newUndoRedo
	_last_patterns_snapshot = _deep_copy_patterns(resource.patterns)
	resource.changed.connect(_rebuild)
	resource.stateUpdated.connect(func(actionMessage: String) -> void:
		var returnValue := _validateResource()
		var errorCount := returnValue.x
		var unmergedPatternCount := returnValue.y
		ResourceSaver.save(resource)
		if errorCount > 0:
			ValidationErrorFixed.emit()
		FixableErrorsFound.emit(unmergedPatternCount)

		var new_patterns = _deep_copy_patterns(resource.patterns)

		undoRedo.create_action("Beatmap | %s"%[actionMessage])
		undoRedo.add_do_method(self, "_apply_snapshot", new_patterns)
		undoRedo.add_undo_method(self, "_apply_snapshot", _last_patterns_snapshot)
		undoRedo.commit_action(false)

		_last_patterns_snapshot = new_patterns
	)
	var inspector := EditorInterface.get_inspector()
	inspector.property_edited.connect(func(property: String) -> void:
		_rebuild()
	)
	_rebuild()

func _apply_snapshot(patterns: Dictionary[String, Array]) -> void:
	_last_patterns_snapshot = _deep_copy_patterns(patterns)
	resource.patterns = patterns
	ValidationErrorFixed.emit()

func _validateResource() -> Vector2i:
	var errorCount := 0
	var unmergedPatternCount := 0
	for key: String in resource.patterns.keys():
		var x = int(key.split("-")[0])
		var y = int(key.split("-")[1])

		var value = resource.patterns[key]
		var previousPattern: BeatmapPatternData
		var selector := str(Pattern.letters[x]) + str(y + 1)
		var debugPos := "[%s/%d-%d]"%[selector, x, y]

		if x >= resource.gridSize.x:
			print("FIX %s: Removing value as x is larger than maximum value of %d"%[debugPos, resource.gridSize.x - 1])
			resource.patterns.erase(key)
			errorCount += 1
			continue

		if y >= resource.gridSize.y:
			print("FIX %s: Removing value as y is larger than maximum value of %d"%[debugPos, resource.gridSize.y - 1])
			resource.patterns.erase(key)
			errorCount += 1
			continue

		for pattern: BeatmapPatternData in value:
			var clampedFinishedAt := minf(pattern.finishedAt, resource.audioFile.get_length())
			if pattern.finishedAt < pattern.startedAt:
				print("FIX %s: Removing %s as it has negative duration"%[debugPos, pattern])
				errorCount += 1
				value.remove_at(value.find(pattern))
			elif pattern.startedAt < 0.0:
				print("FIX %s: Removing %s as it has started before time 0"%[debugPos, pattern])
				errorCount += 1
				value.remove_at(value.find(pattern))
			elif clampedFinishedAt - pattern.startedAt == 0.0:
				print("FIX %s: Removing %s as it has length 0"%[debugPos, pattern])
				errorCount += 1
				value.remove_at(value.find(pattern))
			elif previousPattern and pattern.state == previousPattern.state and pattern.startedAt == previousPattern.finishedAt:
				unmergedPatternCount += 1
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

	return Vector2i(errorCount, unmergedPatternCount)

func _apply_auto_fixes() -> int:
	var fixedErrors := 0
	for iteration in range(10):
		var fixesThisIteration := 0
		for key: String in resource.patterns.keys():
			var x = int(key.split("-")[0])
			var y = int(key.split("-")[1])

			var value = resource.patterns[key]
			var previousPattern: BeatmapPatternData
			var selector := str(Pattern.letters[x]) + str(y + 1)
			var debugPos := "[%s/%d-%d]"%[selector, x, y]

			for pattern: BeatmapPatternData in value:
				var clampedFinishedAt := minf(pattern.finishedAt, resource.audioFile.get_length())
				if previousPattern and pattern.state == previousPattern.state and pattern.startedAt == previousPattern.finishedAt:
					print("FIX %s: Merging pattern %s with %s as they have the same state"%[debugPos, previousPattern, pattern])
					fixesThisIteration += 1
					value.remove_at(value.find(pattern))
					previousPattern.finishedAt = pattern.finishedAt
				previousPattern = pattern

		if fixesThisIteration == 0:
			break

		fixedErrors += fixesThisIteration
		fixesThisIteration = 0

	return fixedErrors

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	var controls: BeatmapInspectorWidget = preload("res://addons/beatmap-plugin/BeatmapInspectorWidget.tscn").instantiate()
	controls.Setup(resource, self)
	add_child(controls)
	var validationResult := _validateResource()
	FixableErrorsFound.emit(validationResult.y)
	controls.ApplyAutoFix.connect(func() -> void:
		var errorCount := _apply_auto_fixes()
		FixableErrorsFound.emit(0)
		if errorCount > 0:
			ValidationErrorFixed.emit()
	)

func _deep_copy_patterns(patterns: Dictionary[String, Array]) -> Dictionary[String, Array]:
	var copy: Dictionary[String, Array] = {}
	for key in patterns:
		var arr: Array = []
		for pattern: BeatmapPatternData in patterns[key]:
			arr.append(pattern.duplicate())
		copy[key] = arr
	return copy
