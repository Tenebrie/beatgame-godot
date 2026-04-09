class_name PerkImmolation extends Perk

static var BaseDamage := 0.6

func _ready() -> void:
	super._ready()
	player.onTakeTurn.connect(_onTakeTurn)

func _onTakeTurn() -> void:
	var effect := preload("res://player/perks/PerkImmolationEffect.tscn").instantiate()
	add_child(effect)
	var dancers := GlobalContext.GetDanceFloor().GetAllDancers()
	for dancer: Dancer in dancers:
		if dancer is Player or not dancer.isAlive:
			continue
		var distanceTo := dancer.position.distance_to(player.position)
		if distanceTo <= 1.9:
			dancer.DealDamage(BaseDamage)
		if Player.HasPerk(PerkProperIgnition):
			Buff.Apply(BuffIgnite, dancer)
	await get_tree().create_timer(0.01).timeout
	effect.get_child(0).emitting = false
	await get_tree().create_timer(1.00).timeout
	effect.queue_free()

static func Build() -> Definition:
	return Definition.new() \
		.SetRarity(Perk.Rarity.Common) \
		.Name("Immolation") \
		.Description("Once per beat, deal damage to all enemies in melee range, including diagonals.") \
		.Description("[b]Damage: [/b] %.2f"%[BaseDamage]) \
		.ProvidesTag(Perk.Tag.Damage) \
