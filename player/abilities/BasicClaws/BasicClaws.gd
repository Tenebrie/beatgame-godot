class_name BasicClaws extends Ability

func _ready() -> void:
	SignalBus.OnBasicBeat.connect(onBasicBeat)

func onBasicBeat() -> void:
	var danceFloor := GlobalContext.GetDanceFloor()
	var dancers := danceFloor.GetAllDancers()
	for dancer: Dancer in dancers:
		if dancer is Player or not dancer.isAlive:
			continue

		var distance := dancer.GridPosition.distance_to(player.GridPosition)
		if distance > 1.0:
			continue

		dancer.DealDamage(1.0)

		var effect := Asset.Instantiate(BasicClawsStrikeEffect) as BasicClawsStrikeEffect
		effect.position = dancer.global_position + Vector3(0, 0.1, 0)
		effect.rotate(Vector3.UP, -PI / 2.0)
		get_tree().root.add_child(effect)
		effect.Play()
