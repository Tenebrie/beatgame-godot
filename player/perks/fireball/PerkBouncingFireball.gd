class_name PerkBouncingFireball extends Perk

## TODO: Implementation

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Bouncing Fireball") \
		.Description("Your fireballs can bounce off an enemy towards another one, resetting their duration.") \
		.Description("[b]Total bounces: [/b] %d"%[BasicFireball.GetBounce() + 1]) \
		.MaxLevel(3) \
		.RequiresAbility(BasicFireball) \
		.ImplementedBy(PerkBouncingFireball)
