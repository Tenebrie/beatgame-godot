class_name Phalanx extends Dancer

func _ready() -> void:
	super._ready()
	SignalBus.OnFullBeat.connect(onBeat)

func onBeat(beat: float) -> void:
	if roundi(beat) % 16 == 0:
		StepTo(GlobalContext.GetPlayer().GridPosition + Vector2i(2, 0))
		var pattern: BeatmapAttack = preload("res://dancers/Phalanx/PhalanxSpearWave.tres")
		Pattern.Translate(Vector2i(-5, -1))
		BeatmapLoader.LoadAttack(pattern, BeatmapTransform.FromTranslation(GridPosition))
		Pattern.Translate(Vector2i(5, 1))
	elif roundi(beat) % 2 == 0:
		StepTo(GlobalContext.GetPlayer().GridPosition + Vector2i(2, 0))
		var pattern: BeatmapAttack = preload("res://dancers/Phalanx/PhalanxQuickThrust.tres")
		Pattern.Translate(Vector2i(-4, 0))
		BeatmapLoader.LoadAttack(pattern, BeatmapTransform.FromTranslation(GridPosition))
		Pattern.Translate(Vector2i(4, 0))
