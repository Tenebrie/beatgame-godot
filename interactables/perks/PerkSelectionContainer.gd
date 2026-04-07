class_name PerkSelectionContainer extends Control

signal onPerkSelected

var animationTimers: Array[SceneTreeTimer]
var animationTweens: Array[Tween]

var skipping := false

func _ready() -> void:
	while get_child_count() > 0:
		var child := get_child(0)
		child.queue_free()
		remove_child(child)

func AddPerk(definition: Perk.Definition) -> PerkSelectionButton:
	var button := Asset.Instantiate(PerkSelectionButton) as PerkSelectionButton
	add_child(button)
	button.Setup(definition)
	button.perkSelected.connect(onPerkSelected.emit)
	animateButton(button)
	return button

func IsAnimating() -> bool:
	var timers := animationTimers.size() > 0 and animationTimers.any(func(timer: SceneTreeTimer) -> bool:
		return timer.time_left > 0
	)
	var tweens := animationTweens.size() > 0 and animationTweens.any(func(tween: Tween) -> bool:
		return tween.is_running()
	)
	return timers or tweens

func SkipAnimation() -> void:
	skipping = true
	for timer: SceneTreeTimer in animationTimers:
		timer.time_left = 0
	for tween: Tween in animationTweens:
		tween.custom_step(100000.0)

func animateButton(button: PerkSelectionButton) -> void:
	button.modulate = Color(Color.WHITE, 0.0)
	var timeoutDuration := button.get_index() * 0.1
	var animationTimer := get_tree().create_timer(timeoutDuration)
	animationTimers.append(animationTimer)
	await animationTimer.timeout
	var targetPosition := button.position
	button.position = targetPosition + Vector2(500, 0)
	var positionTween := create_tween()
	var modulateTween := create_tween()
	positionTween.tween_property(button, ^"position", targetPosition, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	modulateTween.tween_property(button, ^"modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animationTweens.append(positionTween)
	animationTweens.append(modulateTween)
	if skipping:
		SkipAnimation()
