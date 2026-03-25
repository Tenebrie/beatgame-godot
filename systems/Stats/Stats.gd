extends Node

var maxBasicAttacks := 0
var totalDamageTaken := 0.0

func RecordBasicAttackTrigger() -> void:
	maxBasicAttacks += 1

func CalculateOptimalDamage() -> float:
	return maxBasicAttacks
	
func RecordDamageTaken(damage: float) -> void:
	totalDamageTaken += damage
