@tool
class_name PatternTileButton extends Button

var parent: BeatmapInspectorWidget

var state := Beatmap.PatternState.Destroyed
signal MouseDown(event: InputEventMouseButton)
signal StateChangeRequested(to: Beatmap.PatternState)
signal BeforeToolInvoked

var hoveredAlready := false

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

func _init(newParent: BeatmapInspectorWidget) -> void:
	parent = newParent

func _ready() -> void:
	mouse_entered.connect(func() -> void:
		if parent.dragMode != BeatmapInspectorWidget.DragMode.Pattern:
			return

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_apply_selected_tool()
	)
	gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
			_apply_selected_tool()
			MouseDown.emit(event)
	)

func _apply_selected_tool():
	var nextState := Beatmap.PatternState.Idle
	if parent.toolMode == BeatmapInspectorWidget.TileTool.Restore:
		nextState = Beatmap.PatternState.Idle
	elif parent.toolMode == BeatmapInspectorWidget.TileTool.Telegraph:
		nextState = Beatmap.PatternState.Telegraph
	elif parent.toolMode == BeatmapInspectorWidget.TileTool.Destroy:
		nextState = Beatmap.PatternState.Destroyed
	elif parent.toolMode == BeatmapInspectorWidget.TileTool.FullClear:
		nextState = Beatmap.PatternState.Destroyed

	BeforeToolInvoked.emit()
	StateChangeRequested.emit(nextState)

func _input(event: InputEvent):
	if event is InputEventMouseButton and not event.pressed and event.button_index == 1:
		hoveredAlready = false
