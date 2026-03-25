extends Node

var basicAttack: BasicAttack

func _ready() -> void:
	basicAttack = BasicAttack.new()
	add_child(basicAttack)
