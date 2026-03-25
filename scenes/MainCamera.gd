extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

enum CameraMode { None, FollowingPlayer, FollowingDanceFloor }
	

var mode := CameraMode.FollowingPlayer

func _process(delta: float) -> void:
	if mode != CameraMode.FollowingDanceFloor and AudioSystem.IsSongStarted():
		mode = CameraMode.FollowingDanceFloor
		create_tween().tween_property(self, ^"position", Vector3(0.0, 4.0, 1.0), 0.5)
	elif mode != CameraMode.FollowingPlayer and not AudioSystem.IsSongStarted():
		mode = CameraMode.FollowingPlayer
		
	if mode == CameraMode.FollowingPlayer:
		var player := GlobalContext.GetPlayer()
		var targetPos := Vector3(player.global_position.x, global_position.y, player.global_position.z + 1)
		global_position = lerp(global_position, targetPos, delta * 2.0)
		
