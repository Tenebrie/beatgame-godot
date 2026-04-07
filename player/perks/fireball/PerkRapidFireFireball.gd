class_name PerkRapidFireFireball extends Perk

static var DamageMultiplier := 0.5

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Epic) \
		.Name("Rapid Fire Fireball") \
		.Description("You fire your rapid fire fireballs at double the rate, but their impact damage is lower.") \
		.Description("[b]Damage per fireball: [/b] x%.2f"%[BasicFireball.GetDamage() * DamageMultiplier]) \
		.RequiresAbility(BasicFireball)
