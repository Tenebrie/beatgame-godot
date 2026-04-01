class_name Dancer extends Node3D

enum Flag {
	Quick = 0,    # Moves twice per beat
	Slow = 1      # Moves once per two beats
}

@onready var Pathing: DancerPathing = $DancerPathing

var Flags: Array[Flag]
var GridPosition := Vector2i.ZERO
var DancerPosition := Vector3.ZERO
var DancerTargetPosition := Vector3.ZERO

signal takeTurn(beat: float)

func _ready() -> void:
	GridPosition = Vector2i(roundi(position.x), roundi(position.z))
	DancerPosition = GridToWorld(GridPosition)
	DancerTargetPosition = DancerPosition
	position = DancerPosition
	SignalBus.OnAnyBeat.connect(func (beat: float) -> void:
		if is_equal_approx(floorf(beat), beat):
			if not Flags.has(Flag.Slow) or floori(beat) % 2 == 0:
				takeTurn.emit(beat)

		if Flags.has(Flag.Quick) and is_equal_approx(floorf(beat) + 0.5, beat):
			takeTurn.emit(beat)
	)

func Step(dir: Vector2i) -> void:
	var newGridPosition := GridPosition + dir
	StepTo(newGridPosition)

func StepTo(newGridPosition: Vector2i) -> void:
	var danceFloor := GlobalContext.GetDanceFloor()
	var targetTile := danceFloor.GetTileAtPosition(newGridPosition)
	if not targetTile or not targetTile.isAlive:
		return

	GridPosition = newGridPosition
	DancerTargetPosition = GridToWorld(GridPosition)

func GridToWorld(gridPosition: Vector2i) -> Vector3:
	return Vector3(gridPosition.x, 0.1, gridPosition.y)

func AddFlag(flag: Flag) -> void:
	if not Flags.has(flag):
		Flags.append(flag)

func AddFlags(flags: Array[Flag]) -> void:
	for flag: Flag in flags:
		AddFlag(flag)

func _process(delta: float) -> void:
	DancerPosition = DancerPosition.lerp(DancerTargetPosition, 30.0 * delta)
	var height := GlobalContext.GetDanceFloor().GetTileAtPosition(GridPosition).position.y
	position = Vector3(DancerPosition.x, height + 0.2, DancerPosition.z)
