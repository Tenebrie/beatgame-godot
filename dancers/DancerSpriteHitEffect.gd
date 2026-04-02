class_name DancerSpriteHitEffect extends Node

var hitShakeTween: Tween
var hitColorTween: Tween

func ApplySpriteDamage(sprite: Sprite3D, _damage: float) -> void:
	if hitShakeTween and hitShakeTween.is_valid():
		hitShakeTween.kill()
	if hitColorTween and hitColorTween.is_valid():
		hitColorTween.kill()

	sprite.modulate = Color.WHITE
	sprite.position = Vector3.ZERO

	hitShakeTween = create_tween()
	hitColorTween = create_tween()

	hitColorTween.tween_property(sprite, "modulate", Color.RED, 0.05)
	hitColorTween.tween_property(sprite, "modulate", Color.WHITE, 0.15).set_trans(Tween.TRANS_ELASTIC)

	# Shake - multiple back-and-forth snaps
	var shake_strength := 0.1
	var shake_count := 4
	var shake_duration := 0.03
	hitShakeTween.tween_property(sprite, "position", Vector3.ZERO, 0.0)
	for i in shake_count:
		var offset := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0.0).normalized() * shake_strength
		hitShakeTween.tween_property(sprite, "position", offset, shake_duration)
		shake_strength *= 0.7  # decay each shake
	hitShakeTween.tween_property(sprite, "position", Vector3.ZERO, shake_duration)
