class_name PlayerPerkManager extends Node3D

@onready var player: Player = get_parent()

var CurrentTags: Array[Perk.Tag]:
	get:
		var result: Array[Perk.Tag]
		for child in get_children():
			if child is not Perk or not child.definition:
				continue
			var perk: Perk = child
			result.append_array(perk.definition.providesTags)
		return result

func Add(perk: Perk) -> void:
	MessageLog.PrintMessage("Added perk: %s"%[perk.definition.perkName])
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

func Get(perk: GDScript) -> Perk:
	for child in get_children():
		if is_instance_of(child, perk):
			return child

	return null
