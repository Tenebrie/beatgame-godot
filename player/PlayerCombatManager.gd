class_name PlayerCombatManager extends Node

var aggroCount := 0
func RegisterAggro(from: Dancer) -> void:
	aggroCount += 1
	from.onDeath.connect(func() -> void:
		aggroCount -= 1
	)

func IsInCombat() -> bool:
	return aggroCount > 0
