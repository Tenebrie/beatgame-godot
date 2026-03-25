extends Node

var maxBasicAttacks := 0

func RecordBasicAttackTrigger() -> void:
	maxBasicAttacks += 1

func CalculateOptimalDamage() -> float:
	return maxBasicAttacks
