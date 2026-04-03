extends Node

@onready var parent: Player = get_parent()

var basicAttack: BasicAttack

func _ready() -> void:
	basicAttack = BasicAttack.new()
	add_child(basicAttack)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mousePosition := getMouseWorldPlanePosition()
		var direction := mousePosition - Vector3(parent.global_position.x, 0.0, parent.global_position.z)
		var angle := Vector3.RIGHT.signed_angle_to(direction, Vector3.UP)
		var targetDirection := Vector3.ZERO
		if angle < PI / 4.0 and angle > -PI / 4.0:
			targetDirection = Vector3.RIGHT
		elif angle > 0 and angle < PI / 2.0 + PI / 4.0:
			targetDirection = Vector3.FORWARD
		elif angle < 0 and angle > -PI / 2.0 - PI / 4.0:
			targetDirection = Vector3.BACK
		else:
			targetDirection = Vector3.LEFT
		basicAttack.SetTargetDirection(targetDirection)

func getMouseWorldPlanePosition() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)

	# Intersect with Y=0 plane
	var plane := Plane(Vector3.UP, 0.0)
	var intersection: Vector3 = plane.intersects_ray(origin, direction)

	if intersection:
		return intersection
	return Vector3.ZERO
