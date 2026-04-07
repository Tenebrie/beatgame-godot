class_name PerkDoubleTime extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Double Time") \
		.Description("Your energy regenerates twice as fast. In essence, you can move twice as much!")
