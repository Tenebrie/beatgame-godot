class_name Dancer extends Node3D

var GridPosition := Vector2i.ZERO
var DancerPosition := Vector3.ZERO
var DancerTargetPosition := Vector3.ZERO

func _ready() -> void:
	GridPosition = Vector2i(roundi(position.x), roundi(position.z))
	DancerPosition = GridToWorld(GridPosition)
	DancerTargetPosition = DancerPosition
	position = DancerPosition

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

func _process(delta: float) -> void:
	DancerPosition = DancerPosition.lerp(DancerTargetPosition, 30.0 * delta)
	var height := GlobalContext.GetDanceFloor().GetTileAtPosition(GridPosition).position.y
	position = Vector3(DancerPosition.x, height + 0.2, DancerPosition.z)
