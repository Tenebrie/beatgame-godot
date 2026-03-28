@tool
class_name PatternTileButton extends Button

var parent: BeatmapInspectorUI

var state := Beatmap.PatternState.Idle
signal StateChanged(to: Beatmap.PatternState)

var hoveredAlready := false
var stateToSetOnHover := Beatmap.PatternState.Idle

func SetState(to: Beatmap.PatternState) -> void:
	state = to
	var color := Color.WHITE
	if state == Beatmap.PatternState.Idle:
		color = Color.WHITE
	elif state == Beatmap.PatternState.Telegraph:
		color = Color.SADDLE_BROWN
	elif state == Beatmap.PatternState.Destroyed:
		color = Color.from_string("#00000010", Color.BLACK)
	self_modulate = color
	StateChanged.emit(to)

func _init(newParent: BeatmapInspectorUI) -> void:
	parent = newParent
	newParent.StartedMassSettingTilePatterns.connect(func(to: Beatmap.PatternState, from: Beatmap.PatternState) -> void:
		stateToSetOnHover = to
	)

func _ready() -> void:


	mouse_entered.connect(func() -> void:
		if state == stateToSetOnHover:
			return

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			SetState(stateToSetOnHover)
	)
	mouse_exited.connect(func() -> void:
		if state == stateToSetOnHover:
			return
	)
	gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
			_cycle_states()

		if event is InputEventMouseMotion and event.button_mask == 1:
			return
	)

func _cycle_states():
	var oldState := state
	var nextState := Beatmap.PatternState.Idle
	if state == Beatmap.PatternState.Idle:
		nextState = Beatmap.PatternState.Telegraph
	elif state == Beatmap.PatternState.Telegraph:
		nextState = Beatmap.PatternState.Destroyed
	elif state == Beatmap.PatternState.Destroyed:
		nextState = Beatmap.PatternState.Idle
	SetState(nextState)
	parent.StartedMassSettingTilePatterns.emit(nextState, oldState)

func _input(event: InputEvent):
	if event is InputEventMouseButton and not event.pressed and event.button_index == 1:
		hoveredAlready = false
