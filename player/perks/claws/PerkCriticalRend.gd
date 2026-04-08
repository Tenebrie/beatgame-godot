class_name PerkCriticalRend extends Perk

var critAccumulator := 0.0

static var CritHitChance := 0.25
static var CritHitDamage := 2.0
static var MaximumLevel := 2

static func Build() -> Definition:
	var currentLevel := Player.CountPerk(PerkCriticalRend)

	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Critical Rend") \
		.Description("Strike twice periodically, dealing critical damage!") \
		.Description("[b]Critical Hit Chance:[/b] %.0f%%"%[CritHitChance * (currentLevel + 1) * 100.0]) \
		.Description("[b]Critical Hit Damage:[/b] %.0f%%"%[(CritHitDamage + 1.0) * 100.0]) \
		.Description("[b]Level: [/b] %d / %d"%[currentLevel + 1, MaximumLevel]) \
		.MaxLevel(MaximumLevel) \
		.RequiresAbility(BasicClaws)
