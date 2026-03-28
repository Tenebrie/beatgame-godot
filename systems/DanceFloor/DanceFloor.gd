## Main fight/movement grid
##
## Call Setup func to provide the starting arguments and initialize the children
@icon("res://assets/icons/editor/DanceFloor.svg")
class_name DanceFloor extends Node3D

@export_group("Theme Overrides")
@export var TileScene: PackedScene = Asset.Resolve(DanceTile)

var maximumGridSize := Vector2i(4, 4)

var tilemap: Array[Array] # Array[Array[DanceTile]]

#region Public API

## Initializes the grid, to be called by the parent map
func Setup(args: InitArgs) -> void:
	maximumGridSize = args.gridSize

	for x in range(maximumGridSize.x):
		tilemap.append([])
		for y in range(maximumGridSize.y):
			var scene := TileScene.instantiate()
			scene.name = "DanceTile-" + str(x) + "-" + str(y)
			scene.position = Vector3(x, 0, y)
			scene.gridX = x
			scene.gridY = y
			add_child(scene)
			tilemap[x].append(scene)

	if args.showLabels:
		const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
		for x in range(maximumGridSize.x):
			var scene := Asset.Instantiate(DanceLabel) as DanceLabel
			scene.set_text(letters[x])
			scene.position = Vector3(x, 0, maximumGridSize.y - 0.5)
			add_child(scene)

		for y in range(maximumGridSize.y):
			var scene := Asset.Instantiate(DanceLabel) as DanceLabel
			scene.set_text(str(y + 1))
			scene.position = Vector3(-0.5, 0, y)
			add_child(scene)

class InitArgs:
	var gridSize := Vector2i(1, 1)
	var showLabels := false

func GetCameraTarget() -> Vector3:
	var livingTiles := 0
	var positionSum := Vector2(0.0, 0.0)
	for x in range(maximumGridSize.x):
		for y in range(maximumGridSize.y):
			var tileAtPos := get_tile_at_position(Vector2(x, y))
			if not tileAtPos or not tileAtPos.isAlive:
				continue

			livingTiles += 1
			positionSum.x += x
			positionSum.y += y

	return Vector3(positionSum.x / livingTiles, 0.0, positionSum.y / livingTiles)

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

func get_tile_at_position(pos: Vector2i) -> DanceTile:
	if pos.x < 0 or pos.x >= maximumGridSize.x or pos.y < 0 or pos.y >= maximumGridSize.y:
		return null
	return tilemap[pos.x][pos.y]

#endregion
