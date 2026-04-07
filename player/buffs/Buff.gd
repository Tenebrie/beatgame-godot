class_name Buff extends Node3D

@onready var parent: DancerBuffManager = get_parent()
@onready var dancer: Dancer = parent.dancer

static func Apply(buff: GDScript, target: Dancer) -> Buff:
	var instance: Buff = buff.new()
	target.buffManager.Add(instance)
	return instance
