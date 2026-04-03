## Main player character
##
## Drag .tscn instead of just adding this node
class_name Player extends Dancer

@onready var abilityController: AbilityController = $AbilityController

const MOVE_REPEAT_DELAY := 0.3
const MOVE_SPEED := 30.0

var held_direction := Vector2i.ZERO
var repeat_timer := 0.0

func _enter_tree() -> void:
	GlobalContext.Register(self)

func _ready() -> void:
	maximumHealth = 4.0
	maximumMetaHealth = 50.0
	regeneration = 1.0 / 16.0 # 1 hp per 16 seconds
	MakeImmune()
	super._ready()
	SetBasicAttackEffectEmitting(false)
	SignalBus.OnFightBegin.connect(func() -> void: SetBasicAttackEffectEmitting(true))

	SignalBus.OnFullBeat.connect(_onBeatStaminaRefill)

	onDamageTaken.connect(func(damage: float) -> void:
		Stats.RecordDamageTaken(damage)
		SpriteHitEffect.ApplySpriteDamage($GoldenAspectSprite/Sprite3D, damage)
	)
	onDeath.connect(func() -> void:
		SignalBus.OnPlayerDeath.emit()
	)

	await get_tree().create_timer(0.01).timeout
	SignalBus.OnDancerMove.emit(GridPosition, Vector2i(-1000, -1000), self)
	SignalBus.OnPlayerMove.emit(GridPosition, Vector2i(-1000, -1000))

	await get_tree().create_timer(0.05).timeout
	ForfeitImmunity()

func _unhandled_input(event: InputEvent) -> void:
	if not isAlive or isImmune:
		return

	if event is InputEventKey:
		var dir := keyToDirection(event.keycode)
		if dir == Vector2i.ZERO:
			return

		if event.pressed and not event.is_echo():
			held_direction = dir
			Step(dir)
			repeat_timer = 0.0
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
			Step(held_direction)

	super._process(delta)

	damageTaken = maxf(0.0, damageTaken - delta * regeneration)

#region Movement
var staminaUsed := 0.0
var maximumStamina := 10.0
var usedStaminaThisBeat := false

func _onBeatStaminaRefill(_beat: float) -> void:
	var regenValue := 1.0
	if usedStaminaThisBeat:
		usedStaminaThisBeat = false
	else:
		staminaUsed = maxf(0.0, staminaUsed - regenValue)

func RefillStamina() -> void:
	staminaUsed = 0.0
	usedStaminaThisBeat = false

func Step(dir: Vector2i) -> void:
	if usedStaminaThisBeat and maximumStamina - staminaUsed < 1.0:
		performBonk(dir)
		return

	if AudioSystem.IsSongStarted():
		if usedStaminaThisBeat:
			staminaUsed += 1.0
		else:
			usedStaminaThisBeat = true
	var oldPos := GridPosition
	super.Step(dir)
	var newPos := GridPosition
	if oldPos != newPos:
		SignalBus.OnPlayerMove.emit(GridPosition, oldPos)

func keyToDirection(keycode: Key) -> Vector2i:
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
#endregion

func SetBasicAttackEffectEmitting(emitting: bool) -> void:
	$PlayerFireEffect/GPUParticles3D.emitting = emitting

func SetBasicAttackTargetingBoss(value: bool) -> void:
	$AbilityController.basicAttack.SetAutoAim(value)
