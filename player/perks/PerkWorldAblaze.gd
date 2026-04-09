class_name PerkWorldAblaze extends Perk

static var BaseHealthRestored := 0.1

func _ready() -> void:
	player.onTakeTurn.connect(func():
		var healing := 0.0
		var dancers := GlobalContext.GetDanceFloor().GetAllDancers()
		for dancer: Dancer in dancers:
			if dancer is Player or not dancer.isAlive:
				healing += BaseHealthRestored

		if healing > 0.0:
			player.RestoreHealth(healing)
	)

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Legendary) \
		.Name("World Ablaze") \
		.Description("On your turn, restore health for each burning enemy.") \
		.Description("[b]Health per enemy: [/b] %.2f"%[BaseHealthRestored]) \
		.RequiresAnyPerk([PerkImmolation, PerkIgnitingFireball]) \
		.RequiresPerk(PerkWildfireFireball)
