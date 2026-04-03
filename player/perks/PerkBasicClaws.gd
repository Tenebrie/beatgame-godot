class_name PerkBasicClaws extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Unique) \
		.Name("Dragon Claws") \
		.Description("Attacks every beat, targeting one enemy in melee range.") \
		.Description("[b]Damage: [/b] 2") \
		.ProvidesAbility(BasicClaws) \
		.ImplementedBy(PerkBasicClaws)
