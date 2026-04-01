class_name Pattern extends Node

var tiles: Array[Vector2i]
var explodeTimer: MusicTimer
var telegraphDelayTimer: MusicTimer

signal beforeTelegraph
signal telegraphStarted
signal beforeTrigger
signal afterTrigger
signal resolved

const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
var startDelay := 0.0

static var builderTime: float = 0.0
static var BuilderTime: float:
	get:
		return builderTime + maxf(0.0, AudioSystem.get_current_beat())
static var BuilderOffset: Vector2i = Vector2i.ZERO

func _init(newTiles: Array[Vector2i]) -> void:
	self.tiles = newTiles
	name = "AttackPatternTile"
	explodeTimer = MusicTimer.Create()
	var offset := BuilderOffset
	explodeTimer.start(BuilderTime)
	explodeTimer.timeout.connect(
		func(_beat: float) -> void:
			beforeTrigger.emit()
			for tile in tiles:
				var x := tile[0] + offset.x
				var y := tile[1] + offset.y
				SignalBus.explodeTile.emit(x, y)
			afterTrigger.emit()
			resolved.emit()
	)

func Telegraph(delay: float) -> Pattern:
	telegraphDelayTimer = MusicTimer.Create()
	telegraphDelayTimer.start(BuilderTime + startDelay - delay, delay)
	var offset := BuilderOffset
	telegraphDelayTimer.timeout.connect(
		func(_beat: float) -> void:
			beforeTelegraph.emit()
			for tile in tiles:
				var x := tile[0] + offset.x
				var y := tile[1] + offset.y
				SignalBus.telegraphTile.emit(Vector2i(x, y), delay)
			telegraphStarted.emit()
	)
	return self

func Push(direction: Vector2i) -> Pattern:
	var offset := BuilderOffset
	beforeTrigger.connect(func() -> void:
		var player := GlobalContext.GetPlayer()
		for tile in tiles:
			var x := tile[0] + offset.x
			var y := tile[1] + offset.y
			if player.GridPosition.x == x and player.GridPosition.y == y:
				player.ForceMoveOnGrid(direction)
				player.DealDamage(1.0)
	)
	return self

func BeforeTelegraph(function: Callable) -> Pattern:
	beforeTelegraph.connect(function)
	return self

func BeforeTrigger(function: Callable) -> Pattern:
	beforeTrigger.connect(function)
	return self

func Delay(delay: float) -> Pattern:
	startDelay = delay
	explodeTimer.move_trigger(delay)
	if is_instance_valid(telegraphDelayTimer):
		telegraphDelayTimer.move_trigger(delay)
	return self

func RestoreTile() -> Pattern:
	var offset := BuilderOffset
	afterTrigger.connect(func() -> void:
		for tile in tiles:
			var x := tile[0] + offset.x
			var y := tile[1] + offset.y
			SignalBus.OnRestoreTile.emit(x, y)
	)
	return self

func DestroyTile() -> Pattern:
	var offset := BuilderOffset
	afterTrigger.connect(func() -> void:
		for tile in tiles:
			var x := tile[0] + offset.x
			var y := tile[1] + offset.y
			SignalBus.OnDestroyTile.emit(x, y)
	)
	return self

func Done() -> void:
	await resolved

static func _resolveSelector(selector: String) -> Vector2i:
	return Vector2i(letters.find(selector[0]), int(selector[1]) - 1)

static func _resolveSelectors(selectors: Array[String]) -> Array[Vector2i]:
	var resolvedSelectors: Array[Vector2i]
	for selector: String in selectors:
		resolvedSelectors.append(_resolveSelector(selector))
	return resolvedSelectors

###========================================
### Static factories
###========================================

static func PlayerPosition(offset := Vector2i(0, 0)) -> Pattern:
	var pattern := Pattern.new([])
	var builderOffset := BuilderOffset
	pattern.beforeTelegraph.connect(func () -> void:
		var pos := GlobalContext.GetPlayer().GridPosition + offset - builderOffset
		pattern.tiles = [Vector2i(pos.x, pos.y)]
	)
	return pattern

static func Single(tile: String) -> Pattern:
	assert(tile.length() == 2 && letters.contains(tile[0]) && !letters.contains(tile[1]), "Tile string must be defined as 'a1'. Received: " + tile)
	return Pattern.new([_resolveSelector(tile)])

static func SingleIndexed(tile: Vector2i) -> Pattern:
	return Pattern.new([tile])

static func Row(row: int) -> Pattern:
	assert(row > 0 && row < 10, "Row must be defined by a single number. Received: " + str(row))
	var danceFloor := GlobalContext.GetDanceFloor()
	var newTiles: Array[Vector2i]
	for i in danceFloor.maximumGridSize.x:
		newTiles.append(Vector2i(i, row - 1))
	return Pattern.new(newTiles)

static func Column(column: String) -> Pattern:
	assert(column.length() == 1 && letters.contains(column[0]), "Column string must be defined by a single letter. Received: " + column)
	var danceFloor := GlobalContext.GetDanceFloor()
	var newTiles: Array[Vector2i]
	for i in danceFloor.maximumGridSize.y:
		newTiles.append(Vector2i(letters.find(column), i))
	return Pattern.new(newTiles)

static func Rect(topLeft: String, bottomRight: String) -> Pattern:
	assert(topLeft.length() == 2 && letters.contains(topLeft[0]) && !letters.contains(topLeft[1]), "Tile string must be defined as 'a1'. Received: " + topLeft)
	assert(bottomRight.length() == 2 && letters.contains(bottomRight[0]) && !letters.contains(bottomRight[1]), "Tile string must be defined as 'a1'. Received: " + bottomRight)

	var startX := letters.find(topLeft[0])
	var startY := int(topLeft[1])
	var endX := letters.find(bottomRight[0])
	var endY := int(bottomRight[1])

	var newTiles: Array[Vector2i]
	for x in range(startX, endX + 1):
		for y in range(startY, endY + 1):
			newTiles.append(Vector2i(x, y - 1))

	return Pattern.new(newTiles)

static func Cast(ability: BossCast) -> Pattern:
	var pattern := Pattern.new([])
	pattern.telegraphStarted.connect(
		func () -> void:
			ability.start_telegraph()
	)
	pattern.resolved.connect(
		func () -> void:
			ability.trigger()
	)
	return pattern

static func Advance(beats: float) -> void:
	builderTime += beats

static func Translate(offset: Vector2i) -> void:
	BuilderOffset += offset

static func StartHere() -> void:
	GlobalContext.GetAudioAgent().set_starting_time(BuilderTime)

static func ResetState() -> void:
	builderTime = 0.0
	BuilderOffset = Vector2i.ZERO
