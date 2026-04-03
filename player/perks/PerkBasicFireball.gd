class_name PerkBasicFireball extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Unique) \
		.Name("Fireball") \
		.Description("Attacks every beat, manifesting a projectile that travels in a straight line.") \
		.Description("[b]Damage: [/b] 1") \
		.Description("[b]Range: [/b] 4 tiles") \
		.ProvidesAbility(BasicFireball) \
		.ImplementedBy(PerkBasicFireball)
