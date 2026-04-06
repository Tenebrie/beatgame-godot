class_name PerkWildfireFireball extends Perk

## TODO: Implementation

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Wildfire Fireball") \
		.Description("When a burning enemy dies, all adjacent enemies also start burning!") \
		.Description("[b]Damage per beat: [/b] %d"%[PerkIgnitingFireball.BaseDamage * 2]) \
		.RequiresAbility(BasicFireball) \
		.RequiresPerk(PerkIgnitingFireball) \
		.ImplementedBy(PerkWildfireFireball)
