class_name PerkReactiveStrike extends Perk

func _ready() -> void:
	SignalBus.OnDancerMove.connect(func(_to: Vector2i, from: Vector2i, dancer: Dancer):
		if dancer.isAlive and dancer is not Player and from.distance_to(player.GridPosition) <= 1.2:
			var claws: BasicClaws = player.abilityController.Get(BasicClaws)
			claws.Strike(dancer)
	)

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Reactive Strike") \
		.Description("If an enemy tries to move away from melee range, you immediately attack them with your claws.") \
		.RequiresAbility(BasicClaws) \
		.RequiresPerk(PerkBasicClaws)
