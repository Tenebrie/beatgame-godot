@tool
## Main fight/movement grid
##
## Call Setup func to provide the starting arguments and initialize the children
@icon("res://assets/icons/editor/DanceFloor.svg")
class_name DanceFloor extends Node3D

signal TilemapUpdated

@export_group("Theme Overrides")
@export var TileScene: PackedScene = Asset.Resolve(DanceTile)

var GridBounds := BoundingBox.new(Vector2i.ZERO, Vector2i(4, 4))
var initialGridSize := Vector2i(4, 4)

var tilemap: Dictionary[Vector2i, DanceTile]

@onready var pathing: DanceFloorPathing = $DanceFloorPathing

#region Public API

class InitArgs:
	var gridSize := Vector2i(1, 1)
	var showLabels := false

## Initializes the grid, to be called by the parent map
func Setup(args: InitArgs) -> void:
	initialGridSize = args.gridSize
	GridBounds = BoundingBox.new(Vector2i.ZERO, args.gridSize)

	for x in range(initialGridSize.x):
		for y in range(initialGridSize.y):
			var scene := TileScene.instantiate()
			scene.name = "DanceTile-" + str(x) + "-" + str(y)
			scene.position = Vector3(x, 0, y)
			add_child(scene)
			tilemap.set(Vector2i(x, y), scene)

	if args.showLabels:
		const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
		for x in range(initialGridSize.x):
			var scene := Asset.Instantiate(DanceLabel) as DanceLabel
			scene.set_text(letters[x])
			scene.position = Vector3(x, 0, initialGridSize.y - 0.5)
			add_child(scene)

		for y in range(initialGridSize.y):
			var scene := Asset.Instantiate(DanceLabel) as DanceLabel
			scene.set_text(str(y + 1))
			scene.position = Vector3(-0.5, 0, y)
			add_child(scene)

func InjectTile(tilePosition: Vector2i) -> DanceTile:
	if tilemap.has(tilePosition):
		return tilemap.get(tilePosition)

	var scene := TileScene.instantiate()
	scene.name = "DanceTile-" + str(tilePosition.x) + "-" + str(tilePosition.y)
	scene.position = Vector3(tilePosition.x, 0, tilePosition.y)
	add_child(scene)
	tilemap.set(tilePosition, scene)

	GridBounds.AddPoint(tilePosition)

	TilemapUpdated.emit()
	return scene

func GetDistances(origin: Vector2i, exclude: Array[Vector2i]) -> Dictionary[int, Array]:
	var result: Dictionary[int, Array]
	var queue: Array[Vector2i] = [origin]
	var visited: Dictionary = {origin: 0}
	var largestSeenDist: int = 0

	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()
		if exclude.has(current):
			continue
		var dist: int = visited[current]
		if dist > largestSeenDist:
			largestSeenDist = dist
		var tilesAtThisDist: Array = result.get_or_add(dist, [])
		tilesAtThisDist.append(current)
		for neighbor: Vector2i in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var next := current + neighbor
			if tilemap.has(next) and not visited.has(next):
				visited[next] = dist + 1
				queue.append(next)

	return result

func GetCameraTarget() -> Vector3:
	var livingTiles := 0
	var positionSum := Vector2(0.0, 0.0)
	for x in range(initialGridSize.x):
		for y in range(initialGridSize.y):
			var tileAtPos := GetTileAtPosition(Vector2(x, y))
			if not tileAtPos or not tileAtPos.isAlive:
				continue

			livingTiles += 1
			positionSum.x += x
			positionSum.y += y

	return Vector3(positionSum.x / livingTiles, 0.0, positionSum.y / livingTiles)

func GetTileAtPosition(pos: Vector2i) -> DanceTile:
	return tilemap.get(pos)

func HasTile(pos: Vector2i) -> bool:
	return tilemap.has(pos)

func IsTileOccupied(pos: Vector2i) -> bool:
	var player := GlobalContext.GetPlayer()
	if player.GridPosition == pos:
		return true

	for child: Node in get_children():
		if child is Dancer and child.GridPosition == pos and child.isAlive:
			return true
	return false
#endregion

#region Internal
func _enter_tree() -> void:
	GlobalContext.Register(self)

func _ready() -> void:
	for child in get_children():
		if child is DanceTile or child is DanceLabel:
			remove_child(child)
			child.queue_free()

func _on_telegraph_tile(x: int, y: int) -> void:
	SignalBus.telegraphTile.emit(x, y)
	var bpmMod: float = AudioSystem.get_current_bpm() / 60.0
	await get_tree().create_timer(bpmMod).timeout
	SignalBus.explodeTile.emit(x, y)

#endregion
