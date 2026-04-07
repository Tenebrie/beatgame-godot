class_name PerkPiercingFireball extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Piercing Fireball") \
		.Description("Your fireballs can now pierce any number of enemies.") \
		.RequiresAbility(BasicFireball)
