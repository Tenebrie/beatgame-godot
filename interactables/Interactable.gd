class_name Interactable extends Node3D

signal onActivated

var GridPosition := Vector2i.ZERO
var ActivationDistance := 1.5
var interactionEnabled := true

func _ready() -> void:
	GridPosition = Vector2i(roundi(position.x), roundi(position.z))
	SignalBus.OnPlayerMove.connect(func(_to: Vector2i, _from: Vector2i) -> void:
		updateActiveState()
	)
	updateActiveState()

func updateActiveState() -> void:
	if not interactionEnabled:
		$Label3D.visible = false
		return

	var player := GlobalContext.GetPlayer()
	if not player:
		return

	if player.GridPosition.distance_to(GridPosition) <= ActivationDistance:
		$Label3D.visible = true
	else:
		$Label3D.visible = false

func EnableInteraction() -> void:
	interactionEnabled = true
	updateActiveState()

func DisableInteraction() -> void:
	interactionEnabled = false
	updateActiveState()

func _unhandled_key_input(event: InputEvent) -> void:
	var player := GlobalContext.GetPlayer()
	if not player or not player.isAlive:
		return

	if event is InputEventKey and event.keycode == Key.KEY_F and event.pressed \
				 and player.GridPosition.distance_to(GridPosition) <= ActivationDistance:
		onActivated.emit()
