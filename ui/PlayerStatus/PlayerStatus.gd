extends Control

func _process(delta: float) -> void:
	var player := GlobalContext.GetPlayer()
	if not player:
		return
	var healthPercent := 1.0 - player.damageTaken / player.maximumHealth
	var healthDisplayPercent: float = pow(healthPercent, 1.5) * 100.0
	$%HealthBar.value = lerp($%HealthBar.value, healthDisplayPercent, 10.0 * delta)

	var metaHealthPercent := 1.0 - player.metaDamageTaken / player.maximumMetaHealth
	var metaHealthDisplayPercent: float = pow(metaHealthPercent, 1.5) * 100.0
	$%MetaHealthBar.value = lerp($%MetaHealthBar.value, metaHealthDisplayPercent, 10.0 * delta)

	var staminaPercent := 1.0 - player.staminaUsed / player.maximumStamina
	$%StaminaBar.value = lerp($%StaminaBar.value, staminaPercent * 100.0, 10.0 * delta)
