class_name DanceFloorPathing extends Node

@onready var parent: DanceFloor = get_parent()

var isGridValid := false
var aStar := AStar2D.new()
var aStarWithoutAgents := AStar2D.new()

func _ready() -> void:
	SignalBus.OnRestoreTile.connect(func (_x: int, _y: int) -> void:
		isGridValid = false
	)
	SignalBus.OnDestroyTile.connect(func (_x: int, _y: int) -> void:
		isGridValid = false
	)
	parent.TilemapUpdated.connect(func() -> void:
		isGridValid = false
	)
	#SignalBus.OnPlayerMove.connect(func(to: Vector2i, from: Vector2i) -> void:
		#initGrid()
		#aStar.set_point_disabled(getTileId(from.x, from.y), false)
		#aStar.set_point_disabled(getTileId(to.x, to.y), true)
	#)
	SignalBus.OnDancerMove.connect(func(to: Vector2i, from: Vector2i, _dancer: Dancer) -> void:
		initGrid()
		if aStar.has_point(getTileId(from.x, from.y)):
			aStar.set_point_disabled(getTileId(from.x, from.y), false)
		if aStar.has_point(getTileId(to.x, to.y)):
			aStar.set_point_disabled(getTileId(to.x, to.y), true)
	)
	SignalBus.OnDancerDeath.connect(func(dancer: Dancer) -> void:
		initGrid()
		aStar.set_point_disabled(getTileId(dancer.GridPosition.x, dancer.GridPosition.y), false)
	)

class NavigationResult:
	var pathFound := false
	var path: Array[Vector2]
	var toDisabled: bool
	var distance: int
	var flightDistance: int

	func _to_string() -> String:
		return "<NavigationResult pathFound=%s path=%s toDisabled=%s distance=%s flightDistance=%s>"\
			%[str(pathFound), str(path), str(toDisabled), str(distance), str(flightDistance)]

enum NavigationFlags {
	AllowPartial,
	IgnoreCollision,
}

func Navigate(from: Vector2i, to: Vector2i, flags: Array[NavigationFlags] = []) -> NavigationResult:
	initGrid()
	var result := NavigationResult.new()
	result.toDisabled = aStar.is_point_disabled(getTileId(to.x, to.y))

	if from == to:
		result.pathFound = true
		return result

	var path := getPath(from, to, flags)
	if path.size() > 0:
		result.pathFound = true
		result.path = path
		result.distance = path.size() - 1
		result.flightDistance = path.size() - 1
	return result

func initGrid() -> void:
	if isGridValid:
		return

	aStar.clear()
	aStarWithoutAgents.clear()
	var danceFloor := GlobalContext.GetDanceFloor()
	var gridSize := danceFloor.GridBounds
	for x in range(danceFloor.GridBounds.position.x, danceFloor.GridBounds.width + 1):
		for y in range(danceFloor.GridBounds.position.y, danceFloor.GridBounds.height + 1):
			var pointId := getTileId(x, y)
			var tile := danceFloor.GetTileAtPosition(Vector2i(x, y))
			if tile and tile.isAlive:
				aStar.add_point(pointId, Vector2i(x, y))
				aStarWithoutAgents.add_point(pointId, Vector2i(x, y))

	for x in range(danceFloor.GridBounds.position.x, danceFloor.GridBounds.width + 1):
		for y in range(danceFloor.GridBounds.position.y, danceFloor.GridBounds.height + 1):
			var pointId := getTileId(x, y)
			if not aStar.has_point(pointId):
				continue
			for neighbourId: int in getNeighbourTileIds(gridSize.size, x, y):
				if aStar.has_point(neighbourId):
					aStar.connect_points(pointId, neighbourId)
					aStarWithoutAgents.connect_points(pointId, neighbourId)
	isGridValid = true

func getTileId(x: int, y: int) -> int:
	return x * 100000 + y

func getNeighbourTileIds(gridSize: Vector2i, x: int, y: int) -> Array[int]:
	var result: Array[int] = []
	if x + 1 < gridSize.x:
		result.append(getTileId(x + 1, y))
	if x - 1 >= 0:
		result.append(getTileId(x - 1, y))
	if y + 1 < gridSize.y:
		result.append(getTileId(x, y + 1))
	if y - 1 >= 0:
		result.append(getTileId(x, y - 1))
	return result

func getPath(from: Vector2i, to: Vector2i, flags: Array[NavigationFlags] = []) -> Array[Vector2]:
	initGrid()

	var aStarToUse := aStar
	if flags.has(NavigationFlags.IgnoreCollision):
		aStarToUse = aStarWithoutAgents

	var fromId := getTileId(from.x, from.y)
	var toId := getTileId(to.x, to.y)
	if not aStarToUse.has_point(fromId) or not aStarToUse.has_point(toId):
		return []

	var fromDisabled := false
	var toDisabled := false
	if aStarToUse.is_point_disabled(fromId):
		fromDisabled = true
		aStarToUse.set_point_disabled(fromId, false)
	if aStarToUse.is_point_disabled(toId):
		toDisabled = true
		aStarToUse.set_point_disabled(toId, false)

	var packedPath := aStarToUse.get_point_path(fromId, toId, flags.has(NavigationFlags.AllowPartial))

	if fromDisabled:
		aStarToUse.set_point_disabled(fromId, true)
	if toDisabled:
		aStarToUse.set_point_disabled(toId, true)

	var path: Array[Vector2]
	for point: Vector2 in packedPath:
		path.append(point)

	return path
