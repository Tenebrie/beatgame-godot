class_name PerkReactiveGrip extends Perk

## TODO: Implementation

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Epic) \
		.Name("Reactive Grip") \
		.Description("If an enemy tries to move away from melee range, they don't. They still trigger Reactive Strike.") \
		.RequiresAbility(BasicClaws) \
		.RequiresPerk(PerkReactiveStrike)
