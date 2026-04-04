@tool
class_name ActGenerator extends Node

var danceFloor: DanceFloor

var occupiedTiles: Array[Vector2i]
var tilesAtDistance: Dictionary[int, Array]

func _ready() -> void:
	danceFloor = GlobalContext.GetDanceFloor()

class PathData:
	signal onCleared

	var endPoint: Vector2i
	var adversariesRemaining: int
	var adversaries: Array[Dancer]

func GeneratePath(origin: Vector2i, steps: int = 40) -> PathData:
	var position := origin
	var pathData := PathData.new()

	for i in range(3):
		danceFloor.InjectTile(position)
		position.x += 1

	position = generatePathSegment(position, steps)

	for x in range(-2, 3):
		for y in range(-2, 3):
			danceFloor.InjectTile(position + Vector2i(x, y))

	occupiedTiles = []
	# Prevent going backwards
	tilesAtDistance = danceFloor.GetDistances(origin + Vector2i(1, 0), [origin])

	var dancerPackCount := 3
	for i in range(1, dancerPackCount + 1):
		var baseDistToSpawn := i * floori(steps / float(dancerPackCount))
		spawnNormalPackAt(baseDistToSpawn, pathData)

	var sortedKeys := tilesAtDistance.keys()
	sortedKeys.sort()
	var furthestTile: int = sortedKeys[-1]

	spawnElitePackAt(furthestTile - 3, pathData)

	pathData.endPoint = position + Vector2i(3, 0)
	if not Engine.is_editor_hint():
		for dancer: Dancer in pathData.adversaries:
			dancer.onDeath.connect(func() -> void:
				pathData.adversaries.remove_at(pathData.adversaries.find(dancer))
				if pathData.adversaries.size() == 0:
					pathData.onCleared.emit()
			)
	return pathData

func GenerateExit(origin: Vector2i) -> void:
	var position := origin
	for i in range(3):
		danceFloor.InjectTile(position)
		position.x += 1

	var victoryTile := danceFloor.InjectTile(position)
	victoryTile.onDancerEnter.connect(func(dancer: Dancer) -> void:
		if dancer is Player:
			MessageLog.PrintMessage("Victory!")
	)

func generatePathSegment(position: Vector2i, steps: int) -> Vector2i:
	var heading := 0.0
	var maxTurn := PI / 6
	var prevPosition := position

	for i in steps:
		# Fill strip at current position
		var perp := Vector2(-sin(heading), cos(heading))
		for offset: int in [-1, 0, 1]:
			var tilePos := position + Vector2i(roundi(perp.x * offset), roundi(perp.y * offset))
			danceFloor.InjectTile(tilePos)

		# Fill gap between previous and current
		if i > 0:
			var diff := position - prevPosition
			if absi(diff.x) + absi(diff.y) > 1: # diagonal step
				# Inject at both intermediate cells
				danceFloor.InjectTile(Vector2i(prevPosition.x + diff.x, prevPosition.y))
				danceFloor.InjectTile(Vector2i(prevPosition.x, prevPosition.y + diff.y))

		# Step forward
		prevPosition = position
		heading += randf_range(-maxTurn, maxTurn)
		heading = clampf(heading, -PI / 2, PI / 2)
		var dir := Vector2(cos(heading), sin(heading))
		position += Vector2i(roundi(dir.x), roundi(dir.y))
	return position

func spawnNormalPackAt(baseDist: int, pathData: PathData) -> void:
	var dancerCount := randi_range(2, 3)
	spawnPack(baseDist, dancerCount, pathData)

func spawnElitePackAt(baseDist: int, pathData: PathData) -> void:
	var dancerCount := randi_range(3, 4)
	spawnPack(baseDist, dancerCount, pathData)

func spawnPack(baseDist: int, dancerCount: int, pathData: PathData) -> void:
	var validDancers: Array[PackedScene]
	validDancers.append(preload("res://dancers/Stormbird/Stormbird.tscn"))
	validDancers.append(preload("res://dancers/WindyElemental/WindyElemental.tscn"))
	var distRange := Vector2i(-2, 1)
	for d in range(dancerCount):
		var isSpawned := false
		for retry in range(3):
			var distToSpawn := baseDist + randi_range(distRange.x, distRange.y)
			var dancerScene: PackedScene = validDancers.pick_random()
			var randomTilePosition: Vector2i = tilesAtDistance[distToSpawn].pick_random()
			if occupiedTiles.has(randomTilePosition):
				continue
			var dancer: Dancer = dancerScene.instantiate()
			dancer.position = Vector3(randomTilePosition.x, 0.2, randomTilePosition.y)
			danceFloor.add_child(dancer)
			pathData.adversaries.append(dancer)
			occupiedTiles.append(randomTilePosition)
			isSpawned = true
			break
		if not isSpawned:
			printerr("Failed to spawn a dancer at range [%d-%d]"%[baseDist + distRange.x, baseDist + distRange.y])

func calculateDistances(origin: Vector2i) -> void:
	var queue: Array[Vector2i] = [origin]
	var visited: Dictionary = {origin: 0}
	var tilemap := GlobalContext.GetDanceFloor().tilemap
	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()
		var dist: int = visited[current]
		for neighbor: Vector2i in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var next := current + neighbor
			if tilemap.has(next) and not visited.has(next):
				visited[next] = dist + 1
				tilemap[next].distanceFromOrigin = dist + 1
				queue.append(next)
