@tool
class_name BeatmapInspectorWidget extends Control

var resource: Beatmap
var positionBeats := 0.0
var positionSeconds := 0.0
var startPositionBeats := 0.0
var startPositionSeconds := 0.0
var loopPositionBeats := INF
var loopPositionSeconds := INF
var gridButtons: Dictionary # Dictionary["x-y", Button]

func Setup(newResource: Beatmap) -> void:
	resource = newResource
	$AudioStreamPlayer.stream = newResource.audioFile
	gridButtons.clear()

var skipNextLeftClickRelease := false

var toolMode := TileTool.Restore
var dragMode := DragMode.None

enum TileTool { Restore, Telegraph, Destroy, FullClear }
enum DragMode { None, Song, Pattern }

func _ready() -> void:
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
	if resource.gridSize.x > 64 or resource.gridSize.y > 64:
		$%ErrorLabel.text = "Grid size too large! (Max: 64x64)"
		return

	$%ErrorLabel.visible = false

	gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventKey:
			accept_event()
			_hotkey(event)
	)

#region Song controls
	$%SongProgress/StartPos.position.x = 0.0
	$%SongProgress/EndPos.position.x = 9999.0
	_update_scrubber_pos()
	$%PlayButton.pressed.connect(func() -> void:
		if $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play(startPositionSeconds)
		else:
			$AudioStreamPlayer.play(positionSeconds)
		_update_pattern_states()
	)
	$%PauseButton.pressed.connect(func() -> void:
		$AudioStreamPlayer.stop()
		_update_pattern_states()
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
	)
	$%OneBackTiny.pressed.connect(func() -> void:
		_seek_relative_beats(-1.0 / 8.0)
	)
	$%OneBack.pressed.connect(func() -> void:
		var delta := -1.0
		if Input.is_key_pressed(KEY_SHIFT):
			delta = -8.0
		_seek_relative_beats(delta)
	)
	$%OneForward.pressed.connect(func() -> void:
		var delta := 1.0
		if Input.is_key_pressed(KEY_SHIFT):
			delta = 8.0
		_seek_relative_beats(delta)
	)
	$%OneForwardTiny.pressed.connect(func() -> void:
		_seek_relative_beats(1.0 / 8.0)
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
	)
#endregion

#region Toolbar
	var buttonGroup := ButtonGroup.new()
	$%PatternTools/RestoreTile.button_group = buttonGroup
	$%PatternTools/Telegraph.button_group = buttonGroup
	$%PatternTools/DestroyTile.button_group = buttonGroup
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
	$%PatternTools/ClearAll.pressed.connect(func() -> void:
		toolMode = TileTool.FullClear
	)
#endregion

#region Pattern grid
	var btnSize := Vector2(32, 32)
	$%GridContainer.columns = resource.gridSize.x
	for y in range(resource.gridSize.y):
		for x in range(resource.gridSize.x):
			var button = PatternTileButton.new(self)
			button.custom_minimum_size = btnSize
			button.StateChanged.connect(func(to: Beatmap.PatternState) -> void:
				_set_current_tile_state(x, y, to)
			)
			button.MouseDown.connect(func(event: InputEventMouseButton) -> void:
				dragMode = DragMode.Pattern
			)
			button.BeforeToolInvoked.connect(func() -> void:
				if toolMode == TileTool.FullClear:
					_clear_all_tile_patterns(x, y, positionBeats)
			)
			$%GridContainer.add_child(button)

			var key := str(x) + "-" + str(y)
			gridButtons[key] = button
#endregion

	_update_pattern_states()

func _hotkey(event: InputEventKey) -> void:
	if event.keycode == Key.KEY_SPACE:
		if $AudioStreamPlayer.playing:
			$%PauseButton.pressed.emit()
		else:
			$%PlayButton.pressed.emit()
	elif event.keycode == Key.KEY_RIGHT and event.pressed:
		$%OneForwardTiny.pressed.emit()
	elif event.keycode == Key.KEY_LEFT and event.pressed:
		$%OneBackTiny.pressed.emit()
	elif event.keycode == Key.KEY_UP and event.pressed:
		$%OneForward.pressed.emit()
	elif event.keycode == Key.KEY_DOWN and event.pressed:
		$%OneBack.pressed.emit()
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
	if not resource.patterns.has(key) or not current:
		var prevPattern := BeatmapPatternData.new()
		prevPattern.state = Beatmap.PatternState.Idle
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
	else:
		var tilePatterns := resource.patterns[key]

		if current.state == state:
			return

		if current.startedAt == time:
			current.state = state
			resource.stateUpdated.emit()
			return

		var lookahead := _get_next_tile_data(x, y)

		# If the next state is the target, just move the trigger point
		if lookahead and lookahead.state == state:
			lookahead.startedAt = time
			current.finishedAt = time
			resource.stateUpdated.emit()
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
	resource.stateUpdated.emit()

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

	startPositionBeats = roundf(precisePosition / 16.0) * 16.0
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

	loopPositionBeats = roundf(precisePosition / 16.0) * 16.0
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

func _update_pattern_states() -> void:
	for y in range(resource.gridSize.y):
		for x in range(resource.gridSize.x):
			var key := str(x) + "-" + str(y)
			var button: PatternTileButton = gridButtons[key]
			var state := _get_current_tile_state(x, y)

			button.SetState(state)

func _clear_all_tile_patterns(x: int, y: int, startingFrom: float) -> void:
	var time := positionBeats
	var key := str(x) + "-" + str(y)
	if not resource.patterns.has(key):
		return
	var patterns := resource.patterns[key]

	var isDeleting := false
	for i in range(patterns.size()):
		var pattern: BeatmapPatternData = patterns[i]
		if pattern.finishedAt < time:
			continue

		if isDeleting:
			patterns.remove_at(i)
			i -= 1
			continue

		pattern.finishedAt = time
		isDeleting = true
