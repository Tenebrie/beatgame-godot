class_name Buff extends Node3D

@onready var parent: Dancer = get_parent()

static func Apply(buff: GDScript, target: Dancer) -> Buff:
	var instance: Buff = buff.new()
	target.buffManager.Add(instance)
	return instance
