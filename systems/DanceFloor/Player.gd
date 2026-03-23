class_name Player extends CharacterBody3D

const GRID_SIZE := 1.0
var GRID_MIN := Vector2(0, 0)
var GRID_MAX := Vector2(3, 3)  # 4x4 grid (0-3)
const MOVE_REPEAT_DELAY := 0.3
const MOVE_SPEED := 30.0  # lerp speed — higher = snappier

var grid_pos := Vector2i(0, 0)
var held_direction := Vector2i.ZERO
var repeat_timer := 0.0
var first_press := true
var target_position := Vector3.ZERO

func _grid_to_world(gp: Vector2i) -> Vector3:
	return Vector3(gp.x, 0, gp.y) * GRID_SIZE
	
func _enter_tree() -> void:
	GlobalContext.Register(self)

func _ready() -> void:
	target_position = _grid_to_world(grid_pos)
	position = target_position

func set_grid_size(size: Vector2i) -> void:
	GRID_MAX = Vector2i(size.x - 1, size.y - 1)

func _unhandled_input(event: InputEvent) -> void:
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
	if held_direction != Vector2i.ZERO:
		repeat_timer += delta
		if repeat_timer >= MOVE_REPEAT_DELAY:
			repeat_timer -= MOVE_REPEAT_DELAY
			_move(held_direction)

	position = position.lerp(target_position, MOVE_SPEED * delta)

func _move(dir: Vector2i) -> void:
	var new_pos := grid_pos + dir
	new_pos.x = clampi(new_pos.x, int(GRID_MIN.x), int(GRID_MAX.x))
	new_pos.y = clampi(new_pos.y, int(GRID_MIN.y), int(GRID_MAX.y))
	grid_pos = new_pos
	target_position = _grid_to_world(grid_pos)

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
