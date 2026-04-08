class_name BasicClaws extends Ability

static var BaseDamage := 1.0
static var BaseRange := 1.0 # tiles

static func GetDamage() -> float:
	var damage := BaseDamage
	damage += Player.CountPerk(PerkClawSharpening) * PerkClawSharpening.BonusDamage
	return damage

static func GetRange() -> float:
	var attackRange := BaseRange
	if Player.HasPerk(PerkLongClawOfTheLaw):
		attackRange += PerkLongClawOfTheLaw.ExtraRangePerLevel * Player.CountPerk(PerkLongClawOfTheLaw)
	return attackRange

func _ready() -> void:
	SignalBus.OnFullBeat.connect(onBasicBeat)

func onBasicBeat(_beat: float) -> void:
	var danceFloor := GlobalContext.GetDanceFloor()
	var dancers := danceFloor.GetAllDancers()
	for dancer: Dancer in dancers:
		if dancer is Player or not dancer.isAlive:
			continue

		var distance := dancer.GridPosition.distance_to(player.GridPosition)
		if distance > GetRange():
			continue

		Strike(dancer)
		if not Player.HasPerk(PerkRoundhouseSwipe):
			return

func Strike(dancer: Dancer) -> void:
	dancer.DealDamage(GetDamage())

	var effect := Asset.Instantiate(BasicClawsStrikeEffect) as BasicClawsStrikeEffect
	effect.rotate(Vector3.UP, -PI / 2.0)
	if dancer.isAlive:
		dancer.add_child(effect)
		effect.position = Vector3(0, 0.1, 0)
	else:
		get_tree().root.add_child(effect)
		effect.position = dancer.global_position + Vector3(0, 0.1, 0)
	effect.Play()

	# Best Defense perk
	if Player.HasPerk(PerkBestDefense):
		Buff.Apply(BuffDamageResist, player)

	# Critical
	if Player.HasPerk(PerkCriticalRend):
		var perk: PerkCriticalRend = Player.GetPerk(PerkCriticalRend)
		var perkCount := Player.CountPerk(PerkCriticalRend)
		perk.critAccumulator += PerkCriticalRend.CritHitChance * perkCount
		if perk.critAccumulator < 1:
			return

		for i in range(floori(perk.critAccumulator)):
			perk.critAccumulator -= 1
			dancer.DealDamage(GetDamage() * PerkCriticalRend.CritHitDamage)

		await get_tree().create_timer(0.1).timeout
		effect = Asset.Instantiate(BasicClawsStrikeEffect) as BasicClawsStrikeEffect
		effect.rotate(Vector3.UP, 0.0)
		if dancer.isAlive:
			dancer.add_child(effect)
			effect.position = Vector3(0, 0.1, 0.15)
		else:
			get_tree().root.add_child(effect)
			effect.position = dancer.global_position + Vector3(0, 0.1, 0.15)
		effect.PlayInverted()
