class_name PerkBirdcatcher extends Perk

func _ready() -> void:
	SignalBus.BeforeDancerMove.connect(func(to: Vector2i, from: Vector2i, dancer: Dancer):
		if dancer.isAlive and dancer is not Player and from.distance_to(player.GridPosition) <= 1.2 and to.distance_to(player.GridPosition) > 1.2:
			Buff.Apply(BuffRooted, dancer)
	)

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Epic) \
		.Name("Birdcatcher") \
		.Description("If an enemy tries to move away from melee range, they don't. They still trigger Reactive Strike.") \
		.RequiresAbility(BasicClaws) \
		.RequiresPerk(PerkReactiveStrike)
