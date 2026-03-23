class_name Pattern extends Node

var tiles: Array[String]
var explodeTimer: SceneTreeTimer
var telegraphTimer: SceneTreeTimer

const letters = 'abcdefghijklmnopqrstuvwxyz'

func _init(newTiles: Array[String]) -> void:
	self.tiles = newTiles
	name = "AttackPatternTile"
	var danceFloor := GlobalContext.GetDanceFloor()
	explodeTimer = danceFloor.get_tree().create_timer(0.0)
	explodeTimer.timeout.connect(
		func() -> void:
			for tile in tiles:
				var x := letters.find(tile[0])
				var y := int(tile[1]) - 1
				SignalBus.explodeTile.emit(x, y)
	)
		
func Telegraph(delay: float) -> Pattern:
	var danceFloor := GlobalContext.GetDanceFloor()
	for tile in tiles:
		var x := letters.find(tile[0])
		var y := int(tile[1]) - 1
		SignalBus.telegraphTile.emit(Vector2i(x, y), delay)
	explodeTimer.time_left += delay
	telegraphTimer = danceFloor.get_tree().create_timer(delay)
	return self

static func Single(tile: String) -> Pattern:
	assert(tile.length() == 2 && letters.contains(tile[0]) && !letters.contains(tile[1]), "Tile string must be defined as 'a1'. Received: " + tile)
	return Pattern.new([tile])
	
static func Row(row: int) -> Pattern:
	assert(row > 0 && row < 10, "Row must be defined by a single number. Received: " + str(row))
	var danceFloor := GlobalContext.GetDanceFloor()
	var newTiles: Array[String]
	for i in danceFloor.gridSize.x:
		newTiles.append(letters[i] + str(row))
	return Pattern.new(newTiles)
	
static func Column(column: String) -> Pattern:
	assert(column.length() == 1 && letters.contains(column[0]), "Column string must be defined by a single letter. Received: " + column)
	var danceFloor := GlobalContext.GetDanceFloor()
	var newTiles: Array[String]
	for i in danceFloor.gridSize.y:
		newTiles.append(column + str(i + 1))
	return Pattern.new(newTiles)
