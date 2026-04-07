class_name PerkBloodyTime extends Perk

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Rare) \
		.Name("Bloody Time") \
		.Description("Push it to the limit! If you're out of energy, you can still move, but you take health damage every time.") \
		.RequiresTag(Perk.Tag.Damage)
