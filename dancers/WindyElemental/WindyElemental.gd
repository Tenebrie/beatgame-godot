class_name WindyElemental extends Dancer

@onready var attackChargeEffect: DancerAttackChargeEffect = $DancerAttackChargeEffect

func _ready() -> void:
	super._ready()
	maximumHealth = 5.0
	onTakeTurn.connect(_onTakeTurn)
	onDamageTaken.connect(func(damage: float) -> void:
		SpriteHitEffect.ApplySpriteDamage($Sprite3D, damage)
	)
	onDeath.connect(func() -> void:
		create_tween().tween_property(self, ^"scale", Vector3(0.001, 0.001, 0.001), 0.3)
	)

var stunnedUntil := -1.0
var isAggroed := false

func _onTakeTurn(beat: float) -> void:
	if beat <= stunnedUntil:
		return

	var player := GlobalContext.GetPlayer()
	if not isAggroed:
		var manhattanDistance := absi(GridPosition.x - player.GridPosition.x) + absi(GridPosition.y - player.GridPosition.y)
		if manhattanDistance > 5:
			return
		else:
			isAggroed = true
			player.combatManager.RegisterAggro(self)

	var attack: BeatmapAttack
	var beatmapTransform: BeatmapTransform.Builder
	var stunDuration := 2
	var chargeDuration := 2

	var directNavigation := Pathing.NavigateToPlayer()

	var backflipDirection: Vector2i
	if GridPosition.x < player.GridPosition.x:
		backflipDirection = Vector2i.RIGHT
	elif GridPosition.x > player.GridPosition.x:
		backflipDirection = Vector2i.LEFT
	elif GridPosition.y > player.GridPosition.y:
		backflipDirection = Vector2i.UP
	elif GridPosition.y < player.GridPosition.y:
		backflipDirection = Vector2i.DOWN

	if directNavigation.distance < 2 and danceFloor.IsTileOccupied(GridPosition - backflipDirection):
		attack = preload("res://dancers/WindyElemental/WindyElementalPush.tres")
		stunDuration = 4
		chargeDuration = 4
		beatmapTransform = BeatmapTransform.FromOrigin(Vector2i(2, 2)).Translate(GridPosition)
	elif directNavigation.distance < 2:
		attack = preload("res://dancers/WindyElemental/WindyElementalBackflip.tres")
		stunDuration = attack.attackDuration
		chargeDuration = attack.attackDuration
		beatmapTransform = BeatmapTransform.FromOrigin(Vector2i(-1, 0)).Translate(GridPosition)
		if GridPosition.x > player.GridPosition.x:
			beatmapTransform.MirrorX()
		elif GridPosition.y > player.GridPosition.y:
			beatmapTransform.Rotate(-90)
		elif GridPosition.y < player.GridPosition.y:
			beatmapTransform.Rotate(90)

		Trigger.Execute(func() -> void:
			for i in range(3):
				StepTo(GridPosition - backflipDirection)
		).Delay(attack.attackDuration).BindTo(self)
	else:
		var validPoints: Array[Vector2i]
		for x in range(-4, 4):
			for y in range(-4, 4):
				var length := Vector2(x, y).length()
				if length >= 3 and length <= 4 and not danceFloor.IsTileOccupied(Vector2i(x, y)):
					validPoints.append(Vector2i(x, y))

		var navigation := Pathing.NavigateToPlayer(validPoints)

		if navigation.pathFound and navigation.path.size() > 0:
			StepTo(navigation.path[0])
			return

		stunDuration = 2
		chargeDuration = 1
		beatmapTransform = BeatmapTransform.FromOrigin(Vector2i(1, 1)).Translate(GridPosition)
		Trigger.Execute(func() -> void:
			var projectile := Asset.Instantiate(WindyElementalProjectile) as WindyElementalProjectile
			get_tree().root.add_child(projectile)
			projectile.global_position = global_position
			projectile.look_at(player.global_position)
		).Delay(1.0).BindTo(self)

	if attack:
		BeatmapLoader.LoadAttack(attack, beatmapTransform)
	stunnedUntil = beat + stunDuration
	attackChargeEffect.StartCharging()
	Trigger.Execute(func() -> void:
		attackChargeEffect.StopCharging()
	).Delay(chargeDuration).BindTo(self)
