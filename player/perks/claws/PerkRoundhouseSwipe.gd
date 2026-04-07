class_name PerkRoundhouseSwipe extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Roundhouse Swipe") \
		.Description("Your claws now attack all enemies in melee range.") \
		.RequiresAbility(BasicClaws) \
		.RequiresPerk(PerkReactiveStrike)
