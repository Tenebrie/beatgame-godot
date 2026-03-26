class_name Player extends CharacterBody3D

const GRID_SIZE := 1.0
const MOVE_REPEAT_DELAY := 0.3
const MOVE_SPEED := 30.0

var GridPosition := Vector2i(0, 0)
var held_direction := Vector2i.ZERO
var repeat_timer := 0.0
var first_press := true
var target_position := Vector3.ZERO

func _grid_to_world(gp: Vector2i) -> Vector3:
	return Vector3(gp.x, 0.1, gp.y) * GRID_SIZE
	
var isAlive := false
var damageTaken := 0.0
var maximumHealth := 5.0

var hit_tween: Tween
var color_tween: Tween

func DealDamage(damage: float) -> void:
	if not isAlive:
		return
	
	damageTaken += damage
	Stats.RecordDamageTaken(damage)
	
	if damageTaken >= maximumHealth:
		isAlive = false
		SignalBus.OnPlayerDeath.emit()

	if hit_tween and hit_tween.is_valid():
		hit_tween.kill()
	if color_tween and color_tween.is_valid():
		color_tween.kill()

	var sprite := $GoldenAspectSprite/Sprite3D
	sprite.modulate = Color.WHITE
	sprite.position = Vector3.ZERO

	hit_tween = create_tween()
	color_tween = create_tween()

	color_tween.tween_property(sprite, "modulate", Color.RED, 0.05)
	color_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15).set_trans(Tween.TRANS_ELASTIC)

	# Shake - multiple back-and-forth snaps
	var shake_strength := 0.1
	var shake_count := 4
	var shake_duration := 0.03
	hit_tween.tween_property(sprite, "position", Vector3.ZERO, 0.0)
	for i in shake_count:
		var offset := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0.0).normalized() * shake_strength
		hit_tween.tween_property(sprite, "position", offset, shake_duration)
		shake_strength *= 0.7  # decay each shake
	hit_tween.tween_property(sprite, "position", Vector3.ZERO, shake_duration)
	
func ForceMoveOnGrid(dir: Vector2i) -> void:
	_move(dir)
	
func _enter_tree() -> void:
	GlobalContext.Register(self)
	
func _ready() -> void:
	target_position = _grid_to_world(GridPosition)
	position = target_position
	await get_tree().create_timer(0.2).timeout
	isAlive = true
	SetBasicAttackEffectEmitting(false)
	SignalBus.OnFightBegin.connect(func() -> void: SetBasicAttackEffectEmitting(true))

func _unhandled_input(event: InputEvent) -> void:
	if not isAlive:
		return
		
	if event is InputEventKey:
		var dir := _key_to_direction(event.keycode)
		if dir == Vector2i.ZERO:
			return

		if event.pressed and not event.is_echo():
			held_direction = dir
			_move(dir)
			repeat_timer = 0.0
			first_press = true
		elif not event.pressed:
			if dir == held_direction:
				held_direction = Vector2i.ZERO
				repeat_timer = 0.0

func _process(delta: float) -> void:
	if not isAlive:
		return
		
	if held_direction != Vector2i.ZERO:
		repeat_timer += delta
		if repeat_timer >= MOVE_REPEAT_DELAY:
			repeat_timer -= MOVE_REPEAT_DELAY
			_move(held_direction)

	position = position.lerp(target_position, MOVE_SPEED * delta)
	damageTaken = maxf(0.0, damageTaken - delta / 16.0)

func _move(dir: Vector2i) -> void:
	var danceFloor := GlobalContext.GetDanceFloor()
	var new_pos := GridPosition + dir
	var targetTile := danceFloor.get_tile_at_position(new_pos)
	if not targetTile or not targetTile.isAlive:
		return
	
	var old_pos := GridPosition
	GridPosition = new_pos
	target_position = _grid_to_world(GridPosition)
	SignalBus.OnPlayerMove.emit(GridPosition, old_pos)

func _key_to_direction(keycode: Key) -> Vector2i:
	match keycode:
		KEY_W, KEY_UP:
			return Vector2i(0, -1)
		KEY_S, KEY_DOWN:
			return Vector2i(0, 1)
		KEY_A, KEY_LEFT:
			return Vector2i(-1, 0)
		KEY_D, KEY_RIGHT:
			return Vector2i(1, 0)
		_:
			return Vector2i.ZERO

func SetBasicAttackEffectEmitting(emitting: bool) -> void:
	$PlayerFireEffect/GPUParticles3D.emitting = emitting

func SetBasicAttackTargetingBoss(value: bool) -> void:
	$AbilityController.basicAttack.SetAutoAim(value)
