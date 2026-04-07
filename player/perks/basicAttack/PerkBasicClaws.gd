class_name PerkBasicClaws extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Dragon Claws") \
		.Description("Attacks every beat, targeting one enemy in melee range.") \
		.Description("[b]Damage: [/b] %.2f"%[BasicClaws.GetDamage()]) \
		.ProvidesAbility(BasicClaws) \
		.ProvidesTag(Perk.Tag.BasicAttack) \
		.AvoidsTag(Perk.Tag.BasicAttack)
