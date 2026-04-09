class_name PerkBasicFireball extends Perk

func _ready() -> void:
	super._ready()
	var effect := Asset.Instantiate(PerkBasicFireballPlayerEffect) as PerkBasicFireballPlayerEffect
	add_child(effect)
	effect.position = Vector3(0.276, 0.09, 0.0)

static func Build() -> Definition:
	return Definition.new()
		.SetRarity(Perk.Rarity.Common)
		.Name("Fireball")
		.Description("Attacks every beat, manifesting a projectile that travels in a straight line.")
		.Description("[b]Damage: [/b] %.2f"%[BasicFireball.GetDamage()])
		.Description("[b]Range: [/b] %d tiles"%[BasicFireball.MaxRange])
		.ProvidesAbility(BasicFireball)
		.ProvidesTag(Perk.Tag.BasicAttack)
		.ProvidesTag(Perk.Tag.Damage)
		.AvoidsTag(Perk.Tag.BasicAttack)
