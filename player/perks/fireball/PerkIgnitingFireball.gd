class_name PerkIgnitingFireball extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Igniting Fireball") \
		.Description("Your fireballs set enemies on fire, dealing periodic damage. Stacks infinitely.") \
		.Description("[b]Damage per beat: [/b] %.2f"%[BuffIgnite.GetDamage()]) \
		.RequiresAbility(BasicFireball)
