class_name Stormbird extends Dancer

func _ready() -> void:
	super._ready()
	takeTurn.connect(onTakeTurn)

var stunnedUntil := -1.0

func onTakeTurn(beat: float) -> void:
	if beat <= stunnedUntil:
		return

	var validPoints: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	validPoints.append_array([Vector2i(-2, 0), Vector2i(2, 0), Vector2i(0, 2), Vector2i(0, -2)])
	validPoints.append_array([Vector2i(-3, 0), Vector2i(3, 0), Vector2i(0, 3), Vector2i(0, -3)])
	var navigation := Pathing.NavigateToPlayer(validPoints)
	if not navigation.pathFound:
		return

	if navigation.path.size() > 0:
		StepTo(navigation.path[0])
		return

	var player := GlobalContext.GetPlayer()
	var attack: BeatmapAttack
	var beatmapTransform: BeatmapTransform.Builder
	var stunDuration := 2

	print(roundi(beat), " - ", roundi(beat) % 8 == 0)
	if navigation.distance >= 2 and roundi(beat) % 8 == 0:
		attack = preload("res://dancers/Stormbird/attacks/StormbirdFeatherStorm.tres")
		stunDuration = 2
		beatmapTransform = BeatmapTransform.FromOrigin(Vector2i(0, 1)).Translate(GridPosition)
		if GridPosition.x > player.GridPosition.x:
			beatmapTransform.MirrorX()
		elif GridPosition.y > player.GridPosition.y:
			beatmapTransform.Rotate(-90)
		elif GridPosition.y < player.GridPosition.y:
			beatmapTransform.Rotate(90)
		else:
			return
	elif navigation.distance >= 2:
		var direction: Vector2i
		attack = preload("res://dancers/Stormbird/attacks/StormbirdForwardSwoop.tres")
		stunDuration = attack.attackDuration
		beatmapTransform = BeatmapTransform.FromOrigin(Vector2i(-1, 0)).Translate(GridPosition)
		if GridPosition.x < player.GridPosition.x:
			direction = Vector2i.RIGHT
		elif GridPosition.x > player.GridPosition.x:
			direction = Vector2i.LEFT
			beatmapTransform.MirrorX()
		elif GridPosition.y > player.GridPosition.y:
			direction = Vector2i.UP
			beatmapTransform.Rotate(-90)
		elif GridPosition.y < player.GridPosition.y:
			direction = Vector2i.DOWN
			beatmapTransform.Rotate(90)
		else:
			return

		Trigger.Execute(func() -> void:
			for i in range(5):
				StepTo(GridPosition + direction)
		).Delay(attack.attackDuration)
	else:
		attack = preload("res://dancers/Stormbird/attacks/StormbirdRoundhouseSwipe.tres")
		stunDuration = attack.attackDuration
		beatmapTransform = BeatmapTransform.FromOrigin(Vector2i(1, 1)).Translate(GridPosition)

	BeatmapLoader.LoadAttack(attack, beatmapTransform)
	stunnedUntil = beat + stunDuration
