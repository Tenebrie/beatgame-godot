class_name PerkProperIgnition extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Epic) \
		.Name("Proper Ignition") \
		.Description("Your Immolation also applies the same stacking burn effect as your fireball.") \
		.Description("[b]Damage per beat: [/b] %.2f"%[BuffIgnite.GetDamage()]) \
		.RequiresAbility(BasicFireball) \
		.RequiresPerk(PerkImmolation) \
		.RequiresPerk(PerkIgnitingFireball)
