@tool
class_name BeatmapSpeedNudgeButton extends Button

var buttonHoldDelayTimer: Timer
var buttonRepeatTimer: Timer

signal Nudge
var randomBooleanValue := false

func _ready() -> void:
	pressed.connect(func() -> void:
		if randomBooleanValue:
			randomBooleanValue = false
			return

		Nudge.emit()
	)

func _gui_input(input: InputEvent) -> void:
	if input is InputEventMouseButton and input.button_index == MouseButton.MOUSE_BUTTON_LEFT and input.is_pressed():
		buttonHoldDelayTimer = Timer.new()
		add_child(buttonHoldDelayTimer)
		buttonHoldDelayTimer.start(0.2)
		buttonHoldDelayTimer.timeout.connect(func() -> void:
			buttonHoldDelayTimer.queue_free()
			buttonHoldDelayTimer = null

			buttonRepeatTimer = Timer.new()
			add_child(buttonRepeatTimer)
			buttonRepeatTimer.start(0.10)
			buttonRepeatTimer.timeout.connect(func() -> void:
				Nudge.emit()
			)
			randomBooleanValue = true
		)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and not event.is_pressed():
		if buttonHoldDelayTimer:
			buttonHoldDelayTimer.queue_free()
			buttonHoldDelayTimer = null
		if buttonRepeatTimer:
			buttonRepeatTimer.queue_free()
			buttonRepeatTimer = null
