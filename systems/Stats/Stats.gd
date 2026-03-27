extends Node

var maxBasicAttacks := 0
var totalDamageTaken := 0.0

func RecordBasicAttackTrigger() -> void:
	maxBasicAttacks += 1

func CalculateOptimalDamage() -> float:
	return maxBasicAttacks

func RecordDamageTaken(damage: float) -> void:
	totalDamageTaken += damage

func ResetState() -> void:
	maxBasicAttacks = 0
	totalDamageTaken = 0.0
