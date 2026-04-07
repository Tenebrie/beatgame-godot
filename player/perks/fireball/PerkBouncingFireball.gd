class_name PerkBouncingFireball extends Perk

static var MaximumLevel := 3

static func Build() -> Definition:
	var currentLevel := GlobalContext.GetPlayer().perkManager.Count(PerkBouncingFireball)
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Bouncing Fireball") \
		.Description("Your fireballs can bounce off an enemy towards another one, resetting their duration.") \
		.Description("[b]Total bounces: [/b] %d"%[BasicFireball.GetBounce() + 1]) \
		.Description("[b]Level: [/b] %d / %d"%[currentLevel + 1, PerkBouncingFireball.MaximumLevel]) \
		.MaxLevel(MaximumLevel) \
		.RequiresAbility(BasicFireball)
