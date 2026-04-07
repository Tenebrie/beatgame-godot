class_name PerkBestDefense extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Epic) \
		.Name("Best Defense") \
		.Description("After striking an enemy with your claws, your damage taken is halved for one beat.") \
		.RequiresAbility(BasicClaws) \
		.RequiresPerk(PerkReactiveStrike)
