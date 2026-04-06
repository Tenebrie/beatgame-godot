class_name PlayerPerkManager extends Node

func Add(perk: Perk) -> void:
	add_child(perk)

func Has(perk: GDScript) -> bool:
	for child in get_children():
		if is_instance_of(child, perk):
			return true

	return false

func Count(perk: GDScript) -> int:
	var count := 0
	for child in get_children():
		if is_instance_of(child, perk):
			count += 1

	return count
