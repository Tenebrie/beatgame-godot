class_name Dancer extends Node3D

@onready var danceFloor: DanceFloor = get_parent()
@onready var Pathing: DancerPathing = get_node_or_null(^"DancerPathing")
@onready var SpriteHitEffect: DancerSpriteHitEffect = get_node_or_null(^"DancerSpriteHitEffect")

var Flags: Array[Flag]
var GridPosition := Vector2i.ZERO
var DancerPosition := Vector3.ZERO
var DancerTargetPosition := Vector3.ZERO

signal takeTurn(beat: float)

signal onDamageTaken(damage: float)
signal onDeath()

func _ready() -> void:
	GridPosition = Vector2i(roundi(position.x), roundi(position.z))
	DancerPosition = GridToWorld(GridPosition)
	DancerTargetPosition = DancerPosition
	position = DancerPosition
	SignalBus.OnAnyBeat.connect(func (beat: float) -> void:
		if not isAlive:
			return
		if is_equal_approx(floorf(beat), beat):
			if not Flags.has(Flag.Slow) or floori(beat) % 2 == 0:
				takeTurn.emit(beat)

		if Flags.has(Flag.Quick) and is_equal_approx(floorf(beat) + 0.5, beat):
			takeTurn.emit(beat)
	)
	onDeath.connect(func() -> void:
		await get_tree().create_timer(2.0).timeout
		queue_free()
	)

func _process(delta: float) -> void:
	DancerPosition = position.lerp(DancerTargetPosition, 30.0 * delta)
	var height := danceFloor.GetTileAtPosition(GridPosition).position.y
	position = Vector3(DancerPosition.x, height + 0.2, DancerPosition.z)

#region Movement
func Step(dir: Vector2i) -> void:
	var newGridPosition := GridPosition + dir
	StepTo(newGridPosition)

func StepTo(newGridPosition: Vector2i) -> void:
	if danceFloor.IsTileOccupied(newGridPosition):
		performBonk((newGridPosition - GridPosition))
		return

	var targetTile := danceFloor.GetTileAtPosition(newGridPosition)
	if not targetTile or not targetTile.isAlive:
		performBonk((newGridPosition - GridPosition))
		return

	if bonkTween:
		bonkTween.kill()
	var oldPos := GridPosition
	GridPosition = newGridPosition
	DancerTargetPosition = GridToWorld(GridPosition)
	SignalBus.OnDancerMove.emit(GridPosition, oldPos, self)

var bonkTween: Tween
func performBonk(dir: Vector2i) -> void:
	var bumpOffset := Vector3(dir.x, 0, dir.y) * 0.2
	if bonkTween:
		bonkTween.kill()
	bonkTween = create_tween()
	bonkTween.tween_property(self, "position", DancerTargetPosition + bumpOffset, 0.08)
	bonkTween.tween_property(self, "position", DancerTargetPosition, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

func GridToWorld(gridPosition: Vector2i) -> Vector3:
	return Vector3(gridPosition.x, 0.1, gridPosition.y)
#endregion
#region Flags
enum Flag {
	Quick = 0,    # Moves twice per beat
	Slow = 1      # Moves once per two beats
}

func AddFlag(flag: Flag) -> void:
	if not Flags.has(flag):
		Flags.append(flag)

func AddFlags(flags: Array[Flag]) -> void:
	for flag: Flag in flags:
		AddFlag(flag)
#endregion
#region Damage
var isAlive := true
var isImmortal := false

# Disposable health pool, regenerates in fight
var damageTaken := 0.0
var maximumHealth := 5.0
var regeneration := 0.0
# Meta damage, persists in the run
var metaDamageTaken := 0.0
var maximumMetaHealth := 0.0

func DealDamage(damage: float) -> void:
	if not isAlive:
		return

	# Meta health damage overflow
	if damage > maximumHealth - damageTaken:
		var damageRemaining := damage - (maximumHealth - damageTaken)
		metaDamageTaken = minf(metaDamageTaken + damageRemaining, maximumMetaHealth)

	# Normal damage
	damageTaken = minf(damageTaken + damage, maximumHealth)
	onDamageTaken.emit(damage)

	if not isImmortal and damageTaken >= maximumHealth and metaDamageTaken >= maximumMetaHealth:
		isAlive = false
		onDeath.emit()
		SignalBus.OnDancerDeath.emit(self)

func MakeImmortal() -> void:
	isImmortal = true

func ForfeitImmortality() -> void:
	isImmortal = false

func SetMaximumHealth(value: float) -> void:
	maximumHealth = value

func SetRegeneration(value: float) -> void:
	regeneration = value
#endregion
