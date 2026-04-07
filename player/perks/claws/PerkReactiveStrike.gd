class_name PerkReactiveStrike extends Perk

## TODO: Implementation

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Reactive Strike") \
		.Description("If an enemy tries to move away from melee range, you immediately attack them with your claws.") \
		.RequiresAbility(BasicClaws)
