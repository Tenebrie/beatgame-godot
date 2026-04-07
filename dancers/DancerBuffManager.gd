class_name DancerBuffManager extends Node3D

func Add(buff: Buff) -> void:
	add_child(buff)

func Has(buff: GDScript) -> bool:
	for child in get_children():
		if is_instance_of(child, buff):
			return true

	return false

func Count(buff: GDScript) -> int:
	var count := 0
	for child in get_children():
		if is_instance_of(child, buff):
			count += 1

	return count
