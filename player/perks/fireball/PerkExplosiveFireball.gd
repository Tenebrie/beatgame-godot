class_name PerkExplosiveFireball extends Perk

## TODO: Implementation
static var DamageMultipler := 0.5

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Explosive Fireball") \
		.Description("When you hit an enemy, all adjacent enemies also take some of the damage.") \
		.Description("[b]Damage: [/b] %d"%[BasicFireball.GetDamage() * 0.5]) \
		.RequiresAbility(BasicFireball) \
		.ImplementedBy(PerkExplosiveFireball)
