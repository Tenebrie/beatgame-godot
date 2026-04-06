class_name PerkWorldAblaze extends Perk

## TODO: Implementation
static var BaseHealthRestored := 0.1

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Legendary) \
		.Name("World Ablaze") \
		.Description("On your turn, restore health for each burning enemy.") \
		.Description("[b]Health per enemy: [/b] %d"%[BaseHealthRestored]) \
		.RequiresAnyPerk([PerkImmolation, PerkIgnitingFireball]) \
		.RequiresPerk(PerkWildfireFireball)
