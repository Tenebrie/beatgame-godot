class_name PerkIgnitingFireball extends Perk

## TODO: Implementation
static var BaseDamage := 0.5

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Igniting Fireball") \
		.Description("Your fireballs set enemies on fire, dealing periodic damage.") \
		.Description("[b]Damage per beat: [/b] %d"%[BaseDamage * 2]) \
		.RequiresAbility(BasicFireball) \
		.ImplementedBy(PerkIgnitingFireball)
