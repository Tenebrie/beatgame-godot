## Main gameplay camera preset
@icon("res://assets/icons/editor/Camera3D")
class_name MainCamera extends Camera3D

enum Mode { None, AutoFollowPlayer, AutoFollowDanceFloor, ForceFollowPlayer }

var mode := Mode.AutoFollowPlayer

func _ready() -> void:
	_update_camera_state()
	position = desiredTarget

func _process(delta: float) -> void:
	_update_camera_state()
	position = lerp(position, desiredTarget, delta * 2.0)

var desiredTarget := Vector3.ZERO
func _update_camera_state() -> void:
	if mode != Mode.ForceFollowPlayer:
		if mode != Mode.AutoFollowDanceFloor and AudioSystem.IsSongStarted():
			mode = Mode.AutoFollowDanceFloor
		elif mode != Mode.AutoFollowPlayer and not AudioSystem.IsSongStarted():
			mode = Mode.AutoFollowPlayer

	if mode == Mode.AutoFollowDanceFloor:
		var danceFloor := GlobalContext.GetDanceFloor()
		if not danceFloor:
			return
		var cameraTarget := danceFloor.GetCameraTarget()
		desiredTarget = cameraTarget + Vector3(0.0, position.y, 1.0)
	if mode == Mode.AutoFollowPlayer or mode == Mode.ForceFollowPlayer:
		var player := GlobalContext.GetPlayer()
		if player == null:
			return
		desiredTarget = Vector3(player.global_position.x, global_position.y, player.global_position.z + 1)

func SetCameraMode(newMode: Mode) -> void:
	mode = newMode
