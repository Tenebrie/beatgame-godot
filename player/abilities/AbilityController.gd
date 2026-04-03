class_name AbilityController extends Node

@onready var parent: Player = get_parent()

func GetMouseWorldPlanePosition() -> Vector3:
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
