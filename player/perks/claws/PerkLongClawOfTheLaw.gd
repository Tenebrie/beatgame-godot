class_name PerkLongClawOfTheLaw extends Perk

static var MaximumLevel := 2
static var ExtraRangePerLevel := 1

static func Build() -> Definition:
	var currentLevel := Player.CountPerk(PerkLongClawOfTheLaw)

	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Long Claw of the Law") \
		.Description("Your claws now reach further. Increases the range of your attacks.") \
		.Description("[b]Range:[/b] %.f"%[BasicClaws.GetRange() + ExtraRangePerLevel]) \
		.Description("[b]Level: [/b] %d / %d"%[currentLevel + 1, MaximumLevel]) \
		.RequiresAbility(BasicClaws) \
		.MaxLevel(2) \
		.RequiresPerk(PerkReactiveStrike)
