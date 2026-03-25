class_name Pattern extends Node

var tiles: Array[String]
var explodeTimer: MusicTimer
var telegraphDelayTimer: MusicTimer

signal before_telegraph
signal telegraph_started
signal before_trigger
signal after_trigger
signal resolved

const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
var startDelay := 0.0

static var BuilderTime: float = 0.0
static var BuilderOffset: Vector2i = Vector2i.ZERO

func _init(newTiles: Array[String]) -> void:
	self.tiles = newTiles
	name = "AttackPatternTile"
	explodeTimer = MusicTimer.Create()
	var offset := BuilderOffset
	explodeTimer.start(BuilderTime)
	explodeTimer.timeout.connect(
		func(_beat: float) -> void:
			before_trigger.emit()
			for tile in tiles:
				var x := letters.find(tile[0]) + offset.x
				var y := int(tile[1]) - 1 + offset.y
				SignalBus.explodeTile.emit(x, y)
			after_trigger.emit()
			resolved.emit()
	)
		
func Telegraph(delay: float) -> Pattern:
	telegraphDelayTimer = MusicTimer.Create()
	telegraphDelayTimer.start(BuilderTime - delay + startDelay, delay)
	var offset := BuilderOffset
	telegraphDelayTimer.timeout.connect(
		func(_beat: float) -> void:
			before_telegraph.emit()
			for tile in tiles:
				var x := letters.find(tile[0]) + offset.x
				var y := int(tile[1]) - 1 + offset.y
				SignalBus.telegraphTile.emit(Vector2i(x, y), delay)
			telegraph_started.emit()
	)
	return self
	
func BeforeTelegraph(function: Callable) -> Pattern:
	before_telegraph.connect(function)
	return self
	
func BeforeTrigger(function: Callable) -> Pattern:
	before_trigger.connect(function)
	return self
	
func Delay(delay: float) -> Pattern:
	startDelay = delay
	explodeTimer.move_trigger(delay)
	if is_instance_valid(telegraphDelayTimer):
		telegraphDelayTimer.move_trigger(delay)
	return self

func RestoreTile() -> Pattern:
	var offset := BuilderOffset
	after_trigger.connect(func() -> void: 
		for tile in tiles:
			var x := letters.find(tile[0]) + offset.x
			var y := int(tile[1]) - 1 + offset.y
			SignalBus.OnRestoreTile.emit(x, y)
	)
	return self
	
func DestroyTile() -> Pattern:
	var offset := BuilderOffset
	after_trigger.connect(func() -> void: 
		for tile in tiles:
			var x := letters.find(tile[0]) + offset.x
			var y := int(tile[1]) - 1 + offset.y
			SignalBus.OnDestroyTile.emit(x, y)
	)
	return self
	
func Done() -> void:
	await resolved
	
###========================================
### Static factories
###========================================

static func Void() -> Pattern:
	return Pattern.new([])
	
static func PlayerPosition(offset := Vector2i(0, 0)) -> Pattern:
	var pattern := Pattern.new([])
	pattern.before_telegraph.connect(func () -> void:
		var pos := GlobalContext.GetPlayer().grid_pos + offset
		var tile := letters[pos.x] + str(pos.y + 1)
		pattern.tiles = [tile]
	)
	return pattern

static func Single(tile: String) -> Pattern:
	assert(tile.length() == 2 && letters.contains(tile[0]) && !letters.contains(tile[1]), "Tile string must be defined as 'a1'. Received: " + tile)
	return Pattern.new([tile])
	
static func Row(row: int) -> Pattern:
	assert(row > 0 && row < 10, "Row must be defined by a single number. Received: " + str(row))
	var danceFloor := GlobalContext.GetDanceFloor()
	var newTiles: Array[String]
	for i in danceFloor.maximumGridSize.x:
		newTiles.append(letters[i] + str(row))
	return Pattern.new(newTiles)
	
static func Column(column: String) -> Pattern:
	assert(column.length() == 1 && letters.contains(column[0]), "Column string must be defined by a single letter. Received: " + column)
	var danceFloor := GlobalContext.GetDanceFloor()
	var newTiles: Array[String]
	for i in danceFloor.maximumGridSize.y:
		newTiles.append(column + str(i + 1))
	return Pattern.new(newTiles)
	
static func Rect(topLeft: String, bottomRight: String) -> Pattern:
	assert(topLeft.length() == 2 && letters.contains(topLeft[0]) && !letters.contains(topLeft[1]), "Tile string must be defined as 'a1'. Received: " + topLeft)
	assert(bottomRight.length() == 2 && letters.contains(bottomRight[0]) && !letters.contains(bottomRight[1]), "Tile string must be defined as 'a1'. Received: " + bottomRight)
	
	var startX := letters.find(topLeft[0])
	var startY := int(topLeft[1])
	var endX := letters.find(bottomRight[0])
	var endY := int(bottomRight[1])
	
	var newTiles: Array[String]
	for x in range(startX, endX + 1):
		for y in range(startY, endY + 1):
			var tile := letters[x] + str(y)
			newTiles.append(tile)
	
	return Pattern.new(newTiles)
	
static func Cast(ability: BossCast) -> Pattern:
	var pattern := Pattern.new([])
	pattern.telegraph_started.connect(
		func () -> void:
			ability.start_telegraph()
	)
	pattern.resolved.connect(
		func () -> void:
			ability.trigger()
	)
	return pattern
	
static func Advance(beats: float) -> void:
	BuilderTime += beats
	
static func Translate(offset: Vector2i) -> void:
	BuilderOffset += offset
	
static func StartHere() -> void:
	GlobalContext.GetAudioAgent().set_starting_time(BuilderTime)
