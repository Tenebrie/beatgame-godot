class_name PerkCriticalRend extends Perk

## TODO: Implementation
var critAccumulator := 0.0

static var CritHitChance := 0.25
static var MaximumLevel := 2

static func Build() -> Definition:
	var currentLevel := Player.CountPerk(PerkCriticalRend)

	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Critical Rend") \
		.Description("Strike twice periodically, dealing critical damage!") \
		.Description("[b]Critical hit chance:[/b] %.2f"%[CritHitChance * (currentLevel + 1)]) \
		.Description("[b]Level: [/b] %d / %d"%[currentLevel + 1, MaximumLevel]) \
		.MaxLevel(MaximumLevel) \
		.RequiresAbility(BasicClaws)
