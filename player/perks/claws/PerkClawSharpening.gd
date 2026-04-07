class_name PerkClawSharpening extends Perk

static var BonusDamage := 0.5
static var MaximumLevel := 2

static func Build() -> Definition:
	var currentLevel := Player.CountPerk(PerkClawSharpening)

	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Claw Sharpening") \
		.Description("Increase your claws' damage. Simple as that.") \
		.Description("[b]Damage: [/b] %.2f"%[BasicClaws.GetDamage() + BonusDamage]) \
		.Description("[b]Level: [/b] %d / %d"%[currentLevel + 1, MaximumLevel]) \
		.MaxLevel(MaximumLevel) \
		.RequiresAbility(BasicClaws) \
		.RequiresPerk(PerkReactiveStrike)
