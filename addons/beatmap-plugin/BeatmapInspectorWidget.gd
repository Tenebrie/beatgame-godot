@tool
class_name BeatmapInspectorWidget extends Control

signal ApplyAutoFix

var resource: Beatmap
var positionBeats := 0.0
var positionSeconds := 0.0
var startPositionBeats := 0.0
var startPositionSeconds := 0.0
var loopPositionBeats := INF
var loopPositionSeconds := INF
var gridButtons: Dictionary # Dictionary["x-y", Button]

func Setup(newResource: Beatmap, parent: BeatmapEditor) -> void:
	resource = newResource
	$AudioStreamPlayer.stream = newResource.audioFile
	gridButtons.clear()
	parent.ValidationErrorFixed.connect(func() -> void:
		_update_pattern_states()
	)
	parent.FixableErrorsFound.connect(func(count: int) -> void:
		if count > 0:
			$%AutoFixWarning.visible = true
			$%AutoFixWarning/Label.text = "%d keyframe%s can be simplified"%[count, "" if count == 1 else "s"]
		else:
			$%AutoFixWarning.visible = false
	)
	$%AutoFixWarning.visible = false

var skipNextLeftClickRelease := false

var toolMode := TileTool.Restore
var dragMode := DragMode.None

enum TileTool { Restore, Telegraph, Destroy, FindKeyframe, FullClear }
enum DragMode { None, Song, Pattern }

func _ready() -> void:
#region Validation
	if resource == null:
		$%ErrorLabel.text = "Missing resource!"
		return
	if resource.audioFile == null:
		$%ErrorLabel.text = "Missing audio file!"
		return
	if resource.bpm <= 0.0:
		$%ErrorLabel.text = "BPM must be a positive number!"
		return
	if resource.gridSize.x <= 0 or resource.gridSize.y <= 0:
		$%ErrorLabel.text = "Grid size can't be 0!"
		return
	if resource.gridSize.x > 256 or resource.gridSize.y > 52:
		$%ErrorLabel.text = "Grid size too large! (Max: 256x52)"
		return

	$%ErrorLabel.visible = false
#endregion
#region Handle hotkeys
	gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventKey:
			var isHandled := _hotkey(event)
			if isHandled:
				accept_event()
	)
#endregion
#region Song controls
	$%SongProgress/StartPos.position.x = 0.0
	$%SongProgress/EndPos.position.x = 9999.0
	_update_scrubber_pos()
	$%PlayButton.pressed.connect(func() -> void:
		if $AudioStreamPlayer.playing or Input.is_key_pressed(KEY_SHIFT):
			$AudioStreamPlayer.play(startPositionSeconds)
		else:
			$AudioStreamPlayer.play(positionSeconds)
		_update_pattern_states()
		grab_focus(true)
	)
	$%PauseButton.pressed.connect(func() -> void:
		$AudioStreamPlayer.stop()
		_update_pattern_states()
		grab_focus(true)
	)
	$%PauseButton.gui_input.connect(func(event: InputEvent) -> void:
		if event is not InputEventMouseButton or $AudioStreamPlayer.playing:
			return

		if event.pressed:
			$AudioStreamPlayer.play(positionSeconds)
			_update_pattern_states()
		else:
			$AudioStreamPlayer.stop()
			_update_pattern_states()
	)
	$%StopButton.pressed.connect(func() -> void:
		$AudioStreamPlayer.stop()
		positionBeats = startPositionBeats
		positionSeconds = startPositionSeconds
		_update_scrubber_pos()
		_update_pattern_states()
		grab_focus(true)
	)
	$%OneBackTiny.pressed.connect(func() -> void:
		_seek_relative_beats(-1.0 / 8.0)
		grab_focus(true)
	)
	$%OneBack.pressed.connect(func() -> void:
		var delta := -1.0
		if positionBeats - floorf(positionBeats) > 0:
			delta = -(positionBeats - floorf(positionBeats))
		if Input.is_key_pressed(KEY_SHIFT):
			var snappedToDoubleBar := ceilf(positionBeats / 8.0 - 1) * 8.0
			delta = snappedToDoubleBar - positionBeats

		_seek_relative_beats(delta)
		grab_focus(true)
	)
	$%OneForward.pressed.connect(func() -> void:
		var delta := 1.0
		if ceil(positionBeats) - positionBeats > 0:
			delta = ceil(positionBeats) - positionBeats
		if Input.is_key_pressed(KEY_SHIFT):
			var snappedToDoubleBar := floorf(positionBeats / 8.0 + 1) * 8.0
			delta = snappedToDoubleBar - positionBeats
		_seek_relative_beats(delta)
		grab_focus(true)
	)
	$%OneForwardTiny.pressed.connect(func() -> void:
		_seek_relative_beats(1.0 / 8.0)
		grab_focus(true)
	)

	# Song progress controls
	$%SongProgress.gui_input.connect(func(event: InputEvent) -> void:
		if event is not InputEventMouse:
			return

		var inputSize = $%SongProgress.size
		var percentage = clampf(event.position.x / inputSize.x, 0.0, 1.0)

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_key_pressed(KEY_SHIFT):
			_set_song_start_position(percentage)
			skipNextLeftClickRelease = true
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.is_key_pressed(KEY_SHIFT):
			_set_song_loop_position(percentage)
		elif event is InputEventMouseButton and event.button_index == 1 and event.pressed:
			skipNextLeftClickRelease = true
			_set_song_current_position(percentage, true, true)
			dragMode = DragMode.Song
			if not $AudioStreamPlayer.playing:
				$AudioStreamPlayer.play()
		elif event is InputEventMouseMotion and event.button_mask == 1:
			skipNextLeftClickRelease = false
			_set_song_current_position(percentage, true, true)
			if not $AudioStreamPlayer.playing and positionBeats < _get_song_duration_beats():
				$AudioStreamPlayer.play()
		elif event is InputEventMouseButton and event.button_index == 1 and not event.pressed and not skipNextLeftClickRelease:
			_set_song_current_position(percentage, true, true)
			$AudioStreamPlayer.stop()
			_update_scrubber_pos()
		else:
			skipNextLeftClickRelease = false
			return
		_update_pattern_states()
		grab_focus(true)
	)
#endregion
#region Audio playback speed

	var audioBus := AudioBus.new()
	add_child(audioBus)
	var pitchShiftEffect := AudioEffectPitchShift.new()
	pitchShiftEffect.pitch_scale = 1.0
	pitchShiftEffect.resource_name = "Pitch Compensation"
	audioBus.addEffect(pitchShiftEffect)

	var player: AudioStreamPlayer = $AudioStreamPlayer
	player.bus = audioBus.getName()

#endregion
#region Pattern toolbar
	var buttonGroup := ButtonGroup.new()
	$%PatternTools/RestoreTile.button_group = buttonGroup
	$%PatternTools/Telegraph.button_group = buttonGroup
	$%PatternTools/DestroyTile.button_group = buttonGroup
	$%PatternTools/FindKeyframe.button_group = buttonGroup
	$%PatternTools/ClearAll.button_group = buttonGroup

	$%PatternTools/RestoreTile.button_pressed = true

	$%PatternTools/RestoreTile.pressed.connect(func() -> void:
		toolMode = TileTool.Restore
	)
	$%PatternTools/Telegraph.pressed.connect(func() -> void:
		toolMode = TileTool.Telegraph
	)
	$%PatternTools/DestroyTile.pressed.connect(func() -> void:
		toolMode = TileTool.Destroy
	)
	$%PatternTools/FindKeyframe.pressed.connect(func() -> void:
		toolMode = TileTool.FindKeyframe
	)
	$%PatternTools/ClearAll.pressed.connect(func() -> void:
		toolMode = TileTool.FullClear
	)

	for child in $%PatternTools.get_children():
		child.pressed.connect(func() -> void:
			grab_focus(true)
		)
#endregion
#region Pattern grid
	var btnSize := Vector2(48, 48)

	$%GridContainer.columns = resource.gridSize.x + 1
	for y in range(resource.gridSize.y + 1):
		# Row header
		var rowHeaderButton := BeatmapTileButton.new(self)
		$%GridContainer.add_child(rowHeaderButton)
		if y == 0:
			rowHeaderButton.self_modulate = Color.from_hsv(0, 0, 0, 0)
		else:
			rowHeaderButton.text = str(y)
			rowHeaderButton.self_modulate = Color.GRAY

			var rowHeaderControlledTiles: Array[Vector2i]
			for tileX in range(resource.gridSize.x):
				rowHeaderControlledTiles.append(Vector2i(tileX, y - 1))
			_connect_grid_button_events(rowHeaderButton, rowHeaderControlledTiles)
		rowHeaderButton.custom_minimum_size = btnSize

		# Column header
		if y == 0:
			for x in range(resource.gridSize.x):
				var columnHeaderButton := BeatmapTileButton.new(self)
				$%GridContainer.add_child(columnHeaderButton)
				columnHeaderButton.custom_minimum_size = btnSize
				columnHeaderButton.text = BeatmapLetters.letters[x]
				columnHeaderButton.self_modulate = Color.GRAY
				var columnHeaderControlledTiles: Array[Vector2i]
				for tileY in range(resource.gridSize.y):
					columnHeaderControlledTiles.append(Vector2i(x, tileY))
				_connect_grid_button_events(columnHeaderButton, columnHeaderControlledTiles)
			continue

		# Tile buttons
		for x in range(resource.gridSize.x):
			var button = BeatmapTileButton.new(self)
			button.custom_minimum_size = btnSize
			_connect_grid_button_events(button, [Vector2i(x, y - 1)])
			$%GridContainer.add_child(button)

			var keyframeIndicator := Label.new()
			keyframeIndicator.name = "KeyframeIndicator"
			keyframeIndicator.position = Vector2i(24, -3)
			keyframeIndicator.text = "●"
			keyframeIndicator.add_theme_font_size_override("font_size", 8)
			keyframeIndicator.add_theme_color_override("font_color", Color.DARK_GOLDENROD)
			keyframeIndicator.visible = false
			button.add_child(keyframeIndicator)

			var key := str(x) + "-" + str(y - 1)
			gridButtons[key] = button

	$%GridScrollContainer.custom_minimum_size.y = minf(1024.0, $%GridContainer.get_combined_minimum_size().y + 20)
#endregion

	$%ApplyAutoFixButton.pressed.connect(func() -> void:
		ApplyAutoFix.emit()
	)

	_update_pattern_states()

func _connect_grid_button_events(button: BeatmapTileButton, controlledTiles: Array[Vector2i]) -> void:
	button.pressed.connect(func() -> void:
		grab_focus(true)
	)
	button.StateChangeRequested.connect(func(to: Beatmap.PatternState) -> void:
		for tile in controlledTiles:
			var key = str(tile.x) + "-" + str(tile.y)
			gridButtons[key].SetState(to)
			_set_current_tile_state(tile.x, tile.y, to)
	)
	button.MouseDown.connect(func(event: InputEventMouseButton) -> void:
		dragMode = DragMode.Pattern
		grab_focus(true)
	)
	button.BeforeToolInvoked.connect(func() -> void:
		if controlledTiles.size() == 0:
			return
		if toolMode == TileTool.FullClear:
			for tile in controlledTiles:
				_clear_all_tile_patterns(tile.x, tile.y, positionBeats)
		elif toolMode == TileTool.FindKeyframe:
			var tile := controlledTiles[0]
			_find_keyframe_start_tool(tile.x, tile.y)
	)
	button.BeforeAltToolInvoked.connect(func() -> void:
		if controlledTiles.size() == 0:
			return

		var clearKeyframeTools: Array[TileTool] = [TileTool.Restore, TileTool.Telegraph, TileTool.Destroy]
		# Right click to clear keyframe
		if clearKeyframeTools.has(toolMode):
			for tile in controlledTiles:
				_clear_current_tile_keyframe_if_present(tile.x, tile.y)
				_update_single_tile_state(tile.x, tile.y)

		if toolMode == TileTool.FindKeyframe:
			var tile := controlledTiles[0]
			_find_keyframe_end_tool(tile.x, tile.y)
	)

func _hotkey(event: InputEventKey) -> bool:
	if event.keycode == Key.KEY_SPACE and event.pressed and not event.echo:
		if $AudioStreamPlayer.playing and not Input.is_key_pressed(KEY_SHIFT):
			$%PauseButton.pressed.emit()
		else:
			$%PlayButton.pressed.emit()
	elif event.keycode == Key.KEY_T and event.pressed:
		$%StopButton.pressed.emit()
	elif (event.keycode == Key.KEY_UP or event.keycode == Key.KEY_W) and event.pressed:
		$%OneForwardTiny.pressed.emit()
	elif (event.keycode == Key.KEY_DOWN or event.keycode == Key.KEY_S) and event.pressed:
		$%OneBackTiny.pressed.emit()
	elif (event.keycode == Key.KEY_RIGHT or event.keycode == Key.KEY_D) and event.pressed:
		$%OneForward.pressed.emit()
	elif (event.keycode == Key.KEY_LEFT or event.keycode == Key.KEY_A) and event.pressed:
		$%OneBack.pressed.emit()
	elif (event.keycode == Key.KEY_L or event.keycode == Key.KEY_Q) and event.pressed:
		var percentage: float = positionBeats / _get_song_duration_beats()
		_set_song_start_position(percentage)
	elif (event.keycode == Key.KEY_P or event.keycode == Key.KEY_E) and event.pressed:
		var percentage: float = positionBeats / _get_song_duration_beats()
		_set_song_loop_position(percentage)
	elif event.keycode == Key.KEY_1 and event.pressed:
		$%PatternTools/RestoreTile.button_pressed = true
		$%PatternTools/RestoreTile.pressed.emit()
	elif event.keycode == Key.KEY_2 and event.pressed:
		$%PatternTools/Telegraph.button_pressed = true
		$%PatternTools/Telegraph.pressed.emit()
	elif event.keycode == Key.KEY_3 and event.pressed:
		$%PatternTools/DestroyTile.button_pressed = true
		$%PatternTools/DestroyTile.pressed.emit()
	elif event.keycode == Key.KEY_9 and event.pressed:
		$%PatternTools/ClearAll.button_pressed = true
		$%PatternTools/ClearAll.pressed.emit()
	elif event.keycode == Key.KEY_F and event.pressed:
		$%PatternTools/FindKeyframe.button_pressed = true
		$%PatternTools/FindKeyframe.pressed.emit()
	else:
		return false
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and not event.pressed:
		dragMode = DragMode.None

func _seek_relative_beats(beats: float) -> void:
	_set_song_current_position_beats(positionBeats + beats, false, false)
	_update_pattern_states()

func _get_current_tile_state(x: int, y: int, default := Beatmap.PatternState.Destroyed) -> Beatmap.PatternState:
	var time := _get_song_position_beats()
	var key := str(x) + "-" + str(y)
	if not resource.patterns.has(key):
		return default

	var tilePatterns := resource.patterns[key]
	for tilePattern: BeatmapPatternData in tilePatterns:
		if tilePattern.startedAt <= time and tilePattern.finishedAt > time:
			return tilePattern.state
	return default

func _get_current_tile_data(x: int, y: int) -> BeatmapPatternData:
	var time := _get_song_position_beats()
	var key := str(x) + "-" + str(y)
	if not resource.patterns.has(key):
		return null
	var tilePatterns := resource.patterns[key]
	for tilePattern: BeatmapPatternData in tilePatterns:
		if tilePattern.startedAt <= time and tilePattern.finishedAt > time:
			return tilePattern
	return null

func _get_next_tile_data(x: int, y: int) -> BeatmapPatternData:
	var time := _get_song_position_beats()
	var key := str(x) + "-" + str(y)
	var tilePatterns := resource.patterns[key]
	if tilePatterns == null:
		return null

	var currentFound := false
	for tilePattern: BeatmapPatternData in tilePatterns:
		if currentFound:
			return tilePattern
		if tilePattern.startedAt <= time and tilePattern.finishedAt > time:
			currentFound = true
	return null

func _set_current_tile_state(x: int, y: int, state: Beatmap.PatternState) -> void:
	var time := _get_song_position_beats()
	var key := str(x) + "-" + str(y)
	var current := _get_current_tile_data(x, y)
	time = max(0.0, time)

	var stateUpdateMessage: String

	# Patterns exist for this tile, but not at the current time
	if resource.patterns.has(key) and not current and resource.patterns[key].size() > 0:
		if state == Beatmap.PatternState.Destroyed:
			return

		var lookahead: BeatmapPatternData = resource.patterns[key][0]

		# Patterns start later
		if lookahead.startedAt > time:
			var prevPattern := BeatmapPatternData.new()
			prevPattern.state = Beatmap.PatternState.Destroyed
			prevPattern.startedAt = 0.0
			prevPattern.finishedAt = time

			var nextPattern := BeatmapPatternData.new()
			nextPattern.state = state
			nextPattern.startedAt = time
			nextPattern.finishedAt = lookahead.startedAt
			if time > 0.0:
				resource.patterns[key] = [prevPattern, nextPattern] + resource.patterns[key] as Array
			else:
				resource.patterns[key] = [nextPattern] + resource.patterns[key] as Array
			stateUpdateMessage = "[%s] Add leading keyframe at %d"%[_get_selector(x, y), time]

		# Patterns have finished
		else:
			var prevPattern := BeatmapPatternData.new()
			prevPattern.state = Beatmap.PatternState.Destroyed
			prevPattern.startedAt = lookahead.finishedAt
			prevPattern.finishedAt = time

			var nextPattern := BeatmapPatternData.new()
			nextPattern.state = state
			nextPattern.startedAt = time
			nextPattern.finishedAt = _get_song_duration_beats()
			resource.patterns[key] = resource.patterns[key] as Array + [prevPattern, nextPattern]
			stateUpdateMessage = "[%s] Add trailing keyframe at %d"%[_get_selector(x, y), time]

	# No patterns are defined yet
	elif not resource.patterns.has(key) or resource.patterns[key].size() == 0:
		if state == Beatmap.PatternState.Destroyed:
			return

		var prevPattern := BeatmapPatternData.new()
		prevPattern.state = Beatmap.PatternState.Destroyed
		prevPattern.startedAt = 0.0
		prevPattern.finishedAt = time

		var nextPattern := BeatmapPatternData.new()
		nextPattern.state = state
		nextPattern.startedAt = time
		nextPattern.finishedAt = _get_song_duration_beats()

		if time > 0.0:
			resource.patterns[key] = [prevPattern, nextPattern]
		else:
			resource.patterns[key] = [nextPattern]
		stateUpdateMessage = "[%s] Add initial keyframe at beat %s"%[_get_selector(x, y), _format_beat(time)]

	# In the middle of the pattern
	else:
		var tilePatterns := resource.patterns[key]

		if current.state == state and not Input.is_key_pressed(Key.KEY_SHIFT):
			return

		if current.startedAt == time:
			current.state = state
			resource.stateUpdated.emit("[%s] Update keyframe at beat %s"%[_get_selector(x, y), _format_beat(time)])
			return

		var prevPattern := BeatmapPatternData.new()
		prevPattern.state = current.state
		prevPattern.startedAt = current.startedAt
		prevPattern.finishedAt = time

		var nextPattern := BeatmapPatternData.new()
		nextPattern.state = state
		nextPattern.startedAt = time
		nextPattern.finishedAt = current.finishedAt

		var idx := tilePatterns.find(current)
		tilePatterns.remove_at(idx)
		tilePatterns.insert(idx, nextPattern)
		tilePatterns.insert(idx, prevPattern)

		stateUpdateMessage = "[%s] Split keyframe at %s"%[_get_selector(x, y), _format_beat(time)]
	resource.stateUpdated.emit(stateUpdateMessage)
	_update_pattern_states()

func _clear_current_tile_keyframe_if_present(x: int, y: int) -> void:
	var time := _get_song_position_beats()
	var key := str(x) + "-" + str(y)
	if not resource.patterns.has(key):
		return

	var tilePatterns := resource.patterns[key]
	var previousPattern: BeatmapPatternData
	for tilePattern: BeatmapPatternData in tilePatterns:
		if tilePattern.startedAt <= time and tilePattern.finishedAt > time:
			if tilePattern.startedAt != positionBeats:
				return

			resource.patterns[key].remove_at(resource.patterns[key].find(tilePattern))
			if previousPattern:
				previousPattern.finishedAt = tilePattern.finishedAt
			resource.stateUpdated.emit("[%s] Remove keyframe at beat %s"%[_get_selector(x, y), _format_beat(time)])
			return
		previousPattern = tilePattern

func _set_song_current_position(percentage: float, allowPlay: bool, force: bool) -> void:
	if not resource.audioFile:
		return
	var offsetPos := percentage * resource.audioFile.get_length()
	var precisePosition := offsetPos / 60.0 * resource.bpm
	_set_song_current_position_beats(precisePosition, allowPlay, force)

func _set_song_current_position_beats(beats: float, allowPlay: bool, force: bool) -> void:
	var durationFloored := floorf(_get_song_duration_beats() * 8.0) / 8.0
	beats = clamp(beats, 0.0, durationFloored)
	var oldPositionSeconds: float = $AudioStreamPlayer.get_playback_position()

	positionBeats = roundf(beats * 8.0) / 8.0
	positionSeconds = positionBeats * 60.0 / resource.bpm
	if positionBeats < startPositionBeats:
		_set_song_start_position(0.0)
	if positionBeats >= loopPositionBeats:
		_set_song_loop_position(1.0)

	if allowPlay and not $AudioStreamPlayer.is_playing() and positionBeats < _get_song_duration_beats() - 0.5:
		$AudioStreamPlayer.play(startPositionSeconds)
	if allowPlay and (force or positionSeconds != oldPositionSeconds):
		$AudioStreamPlayer.seek(positionSeconds)
	_update_scrubber_pos()

func _set_song_start_position(percentage: float) -> void:
	var offsetPos := percentage * resource.audioFile.get_length()
	var precisePosition := offsetPos / 60.0 * resource.bpm

	var oldStartPositionSeconds := startPositionSeconds

	var snapTo := 1.0
	startPositionBeats = roundf(precisePosition / snapTo) * snapTo
	startPositionSeconds = startPositionBeats * 60.0 / resource.bpm
	if startPositionBeats >= loopPositionBeats:
		_set_song_loop_position(1.0)

	var snappedPercentage = startPositionSeconds / resource.audioFile.get_length()
	if snappedPercentage > 0:
		$%SongProgress/StartPos.position.x = snappedPercentage * $%SongProgress.size.x
	else:
		$%SongProgress/StartPos.position.x = 9999.0

func _set_song_loop_position(percentage: float) -> void:
	var offsetPos := percentage * resource.audioFile.get_length()
	var precisePosition := offsetPos / 60.0 * resource.bpm

	var snapTo := 1.0
	loopPositionBeats = roundf(precisePosition / snapTo) * snapTo
	loopPositionSeconds = loopPositionBeats * 60.0 / resource.bpm
	if startPositionBeats >= loopPositionBeats:
		_set_song_start_position(0.0)

	var snappedPercentage = loopPositionSeconds / resource.audioFile.get_length()
	var targetX: float = snappedPercentage * $%SongProgress.size.x
	if targetX <= $%SongProgress.size.x - 5:
		$%SongProgress/EndPos.position.x = snappedPercentage * $%SongProgress.size.x
	else:
		$%SongProgress/EndPos.position.x = 9999.0

func _get_song_position_beats() -> float:
	if not $AudioStreamPlayer.playing:
		return positionBeats

	var compensation := AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	var offsetPos: float = $AudioStreamPlayer.get_playback_position() + compensation
	var precisePosition := offsetPos / 60.0 * resource.bpm
	var durationFloored := floorf(_get_song_duration_beats() * 8.0) / 8.0
	var beats := clamp(precisePosition, 0.0, durationFloored)
	return roundf(beats * 8.0) / 8.0

func _get_song_duration_beats() -> float:
	var length: float = $AudioStreamPlayer.stream.get_length()
	var precisePosition := length / 60.0 * resource.bpm
	return floorf(precisePosition * 8.0) / 8.0

func _process(_delta: float) -> void:
	if resource == null or not $AudioStreamPlayer.is_playing():
		return
	if $AudioStreamPlayer.is_playing() and $AudioStreamPlayer.get_playback_position() >= _get_song_duration_beats():
		$AudioStreamPlayer.stop()
	elif $AudioStreamPlayer.is_playing() and $AudioStreamPlayer.get_playback_position() >= loopPositionSeconds:
		$AudioStreamPlayer.seek(startPositionSeconds)

	positionBeats = _get_song_position_beats()
	positionSeconds = positionBeats * 60.0 / resource.bpm
	_update_scrubber_pos()
	_update_pattern_states()

func _update_scrubber_pos() -> void:
	if resource.audioFile == null:
		$%SongProgress/Scrubber.position.x = 0.0
		return
	var position := _get_song_position_beats()
	$%BeatIndexLabel.text = str(floori(position))
	var scrubberPosSeconds := position * 60.0 / resource.bpm
	var width: float = $%SongProgress.size.x
	$%SongProgress/Scrubber.position.x = scrubberPosSeconds / resource.audioFile.get_length() * width
	var fraction := positionBeats - floori(positionBeats)
	$%SongProgress/FractionTop.text = str(floori(fraction * 8 + 1))

func _update_single_tile_state(x: int, y: int) -> void:
	var key := str(x) + "-" + str(y)
	var button: BeatmapTileButton = gridButtons[key]
	var data := _get_current_tile_data(x, y)
	var state := data.state if data else Beatmap.PatternState.Destroyed
	var isKeyframe := data.startedAt == positionBeats if data else false

	button.SetState(state)
	var keyframeIndicator := button.get_child(0) as Label
	keyframeIndicator.visible = isKeyframe and positionBeats > 0.0

func _update_pattern_states() -> void:
	for y in range(resource.gridSize.y):
		for x in range(resource.gridSize.x):
			_update_single_tile_state(x, y)

func _clear_all_tile_patterns(x: int, y: int, startingFrom: float) -> void:
	var time := positionBeats
	var key := str(x) + "-" + str(y)
	if not resource.patterns.has(key):
		return
	var patterns := resource.patterns[key]

	var isDeleting := false
	var i: int = 0
	while i < patterns.size():
		var pattern: BeatmapPatternData = patterns[i]
		if pattern.finishedAt < time:
			i += 1
			continue

		if isDeleting:
			patterns.remove_at(i)
			continue

		isDeleting = true
		pattern.finishedAt = time
		if pattern.finishedAt - pattern.startedAt == 0.0 or pattern.state == Beatmap.PatternState.Destroyed:
			patterns.remove_at(i)
		else:
			i += 1
	resource.stateUpdated.emit("[%s] Clear history after beat %s"%[_get_selector(x, y), _format_beat(time)])

func _find_keyframe_start_tool(x: int, y: int) -> void:
	var data := _get_current_tile_data(x, y)

	if data:
		# If we have an active state, start cycling through them
		if positionBeats > data.startedAt:
			_set_song_current_position_beats(data.startedAt, false, false)
		else:
			var key := str(x) + "-" + str(y)
			var index := resource.patterns[key].find(data)
			if index <= 0:
				_set_song_current_position_beats(0.0, false, false)
			else:
				var previous: BeatmapPatternData = resource.patterns[key][index - 1]
				_set_song_current_position_beats(previous.startedAt, false, false)
	else:
		# Otherwise, either find the first state to the left, or snap to song start
		var key := str(x) + "-" + str(y)
		if resource.patterns.has(key) and resource.patterns[key].size() > 0:
			var reversed = resource.patterns[key].slice(0)
			reversed.reverse()
			for pattern in reversed:
				if pattern.finishedAt <= positionBeats:
					_set_song_current_position_beats(pattern.startedAt, false, false)
					break
		else:
			_set_song_current_position_beats(0, false, false)

	_update_pattern_states()

func _find_keyframe_end_tool(x: int, y: int) -> void:
	var data := _get_current_tile_data(x, y)

	if data:
		# If we have an active state, start cycling through them
		_set_song_current_position_beats(data.finishedAt, false, false)
		_update_pattern_states()
	else:
		# Otherwise, either find the first state to the right, or snap to song end
		var key := str(x) + "-" + str(y)
		if resource.patterns.has(key) and resource.patterns[key].size() > 0:
			for pattern in resource.patterns[key]:
				if pattern.startedAt > positionBeats:
					_set_song_current_position_beats(pattern.startedAt, false, false)
					break
		else:
			_set_song_current_position_beats(_get_song_duration_beats(), false, false)

	_update_pattern_states()

func _get_selector(x: int, y: int) -> String:
	return BeatmapLetters.letters[x] + str(y + 1)

func _format_beat(beat: float) -> String:
	var wholePart := floori(beat)
	var fractionalPart := beat - wholePart
	if fractionalPart == 0:
		return str(wholePart)
	else:
		return str(wholePart) + " " + str(roundi(fractionalPart * 8.0) + 1) + "/8"
