class_name PerkIncendiaryFireball extends Perk

## TODO: Implementation

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Epic) \
		.Name("Incendiary Fireball") \
		.Description("Explosive fireball now also applies full damage burn effect. If this ignites at least 3 total targets, main targets takes double burning damage.") \
		.RequiresAbility(BasicFireball) \
		.RequiresPerk(PerkIgnitingFireball) \
		.RequiresPerk(PerkExplosiveFireball) \
		.ImplementedBy(PerkIncendiaryFireball)
