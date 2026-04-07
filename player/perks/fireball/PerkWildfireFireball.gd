class_name PerkWildfireFireball extends Perk

static var MaxRange := 2.0

func _ready() -> void:
	SignalBus.OnDancerDeath.connect(func(dancer: Dancer) -> void:
		if not dancer.buffManager.Has(BuffIgnite):
			return

		var adjacentDancers := GlobalContext.GetDanceFloor().GetAllDancers()
		for adjacent: Dancer in adjacentDancers:
			if adjacent is Player or not adjacent.isAlive or adjacent.position.distance_to(player.position) > MaxRange:
				continue
			Buff.Apply(BuffIgnite, adjacent)
	)

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Wildfire Fireball") \
		.Description("When a burning enemy dies, all enemies in range also start burning!") \
		.Description("[b]Damage per beat: [/b] %.2f"%[BuffIgnite.GetDamage()]) \
		.Description("[b]Range: [/b] %.2f"%[MaxRange]) \
		.RequiresAbility(BasicFireball) \
		.RequiresPerk(PerkIgnitingFireball)
