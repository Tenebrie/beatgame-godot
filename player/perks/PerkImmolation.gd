class_name PerkImmolation extends Perk

## TODO: Implementation
static var BaseDamage := 0.5

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Immolation") \
		.Description("On your turn, deal damage to all enemies in melee range.") \
		.Description("[b]Damage per beat: [/b] %f"%[BaseDamage]) \
		.RequiresPerk(PerkWildfireFireball)
