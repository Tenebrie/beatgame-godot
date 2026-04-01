class_name DancerPathing extends Node

@onready var Parent: Dancer = get_parent()

var isGridValid := false
var aStar := AStar2D.new()

func _ready() -> void:
	SignalBus.OnRestoreTile.connect(func (_x: int, _y: int) -> void:
		isGridValid = false
	)
	SignalBus.OnDestroyTile.connect(func (_x: int, _y: int) -> void:
		isGridValid = false
	)

class NavigationResult:
	var pathFound := false
	var path: Array[Vector2]
	var optionIndex: int = -1
	var distance: int

	func _to_string() -> String:
		return "<NavigationResult pathFound=%s optionIndex=%s path=%s>"%[str(pathFound), str(optionIndex), str(path)]

func NavigateTo(target: Vector2i) -> NavigationResult:
	var result := NavigationResult.new()
	result.optionIndex = 0

	if Parent.GridPosition == target:
		result.pathFound = true
		return result

	var path := getPath(Parent.GridPosition, target)
	if path.size() > 0:
		result.pathFound = true
		result.path = path
	return result

func NavigateToPlayer(desiredOffsets: Array[Vector2i] = [Vector2i.ZERO]) -> NavigationResult:
	var player := GlobalContext.GetPlayer()
	var result := NavigationResult.new()
	if not player:
		return result

	var playerGridPosition := player.GridPosition
	var gridSize := GlobalContext.GetDanceFloor().GridSize

	var directPath := getPath(Parent.GridPosition, playerGridPosition)
	result.distance = directPath.size() - 1

	for offset in desiredOffsets:
		if Parent.GridPosition == playerGridPosition + offset:
			result.path = []
			result.pathFound = true
			result.optionIndex = desiredOffsets.find(offset)
			return result

		var target := playerGridPosition + offset
		if target.x < 0 or target.y < 0 or target.x >= gridSize.x or target.y >= gridSize.y:
			continue

		var path := getPath(Parent.GridPosition, target)
		if path.size() > 0 and (not result.pathFound or result.path.size() > path.size()):
			result.pathFound = true
			result.path = path
			result.optionIndex = desiredOffsets.find(offset)

	if result.pathFound and result.path[0].x == Parent.GridPosition.x and result.path[0].y == Parent.GridPosition.y:
		result.path = result.path.slice(1)
	return result

func initGrid() -> void:
	if isGridValid:
		return

	aStar.clear()
	var danceFloor := GlobalContext.GetDanceFloor()
	var gridSize := danceFloor.GridSize
	for x in range(gridSize.x):
		for y in range(gridSize.y):
			var pointId := getTileId(gridSize, x, y)
			var tile := danceFloor.GetTileAtPosition(Vector2i(x, y))
			if tile.isAlive:
				aStar.add_point(pointId, Vector2i(x, y))

	for x in range(gridSize.x):
		for y in range(gridSize.y):
			var pointId := getTileId(gridSize, x, y)
			if not aStar.has_point(pointId):
				continue
			for neighbourId: int in getNeighbourTileIds(gridSize, x, y):
				if aStar.has_point(neighbourId):
					aStar.connect_points(pointId, neighbourId)
	isGridValid = true

func getTileId(gridSize: Vector2i, x: int, y: int) -> int:
	return y + x * gridSize.y

func getNeighbourTileIds(gridSize: Vector2i, x: int, y: int) -> Array[int]:
	var result: Array[int] = []
	if x + 1 < gridSize.x:
		result.append(getTileId(gridSize, x + 1, y))
	if x - 1 >= 0:
		result.append(getTileId(gridSize, x - 1, y))
	if y + 1 < gridSize.y:
		result.append(getTileId(gridSize, x, y + 1))
	if y - 1 >= 0:
		result.append(getTileId(gridSize, x, y - 1))
	return result

func getPath(from: Vector2i, to: Vector2i) -> Array[Vector2]:
	initGrid()
	var gridSize := GlobalContext.GetDanceFloor().GridSize
	var fromId := getTileId(gridSize, from.x, from.y)
	var toId := getTileId(gridSize, to.x, to.y)
	if not aStar.has_point(fromId) or not aStar.has_point(toId):
		return []
	var packedPath := aStar.get_point_path(fromId, toId)
	var path: Array[Vector2]
	for point: Vector2 in packedPath:
		path.append(point)

	return path
