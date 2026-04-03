class_name BasicClaws extends Ability

func _ready() -> void:
	SignalBus.OnBasicBeat.connect(onBasicBeat)

func onBasicBeat() -> void:
	var danceFloor := GlobalContext.GetDanceFloor()
	var dancers := danceFloor.GetAllDancers()
	for dancer: Dancer in dancers:
		if dancer is Player:
			continue

		var distance := dancer.GridPosition.distance_to(player.GridPosition)
		if distance > 1.0:
			continue

		dancer.DealDamage(2.0)
