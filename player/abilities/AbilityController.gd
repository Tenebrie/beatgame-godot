class_name AbilityController extends Node

#signal onCast(ability: Ability)

@onready var parent: Player = get_parent()

func Add(ability: Ability) -> void:
	add_child(ability)

func Has(ability: GDScript[Ability]) -> bool:
	for child in get_children():
		if is_instance_of(child, ability):
			return true

	return false

func Count(ability: GDScript[Ability]) -> int:
	var count := 0
	for child in get_children():
		if is_instance_of(child, ability):
			count += 1

	return count

func Get(ability: GDScript[Ability]) -> Ability:
	for child in get_children():
		if is_instance_of(child, ability):
			return child

	return null

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
