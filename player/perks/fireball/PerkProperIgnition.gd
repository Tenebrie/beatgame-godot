class_name PerkProperIgnition extends Perk

## TODO: Implementation

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Epic) \
		.Name("Proper Ignition") \
		.Description("Your Immolation also applies the same burn effect as your fireball.") \
		.Description("[b]Damage per beat: [/b] %d"%[PerkIgnitingFireball.BaseDamage * 2]) \
		.RequiresAbility(BasicFireball) \
		.RequiresPerk(PerkImmolation) \
		.RequiresPerk(PerkIgnitingFireball) \
		.ImplementedBy(PerkWildfireFireball)
