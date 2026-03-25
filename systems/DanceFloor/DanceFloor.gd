class_name DanceFloor extends Node3D

@export var tile: PackedScene

var gridSize := Vector2i(4, 4)
var maximumGridSize := Vector2i(32, 4)

var tilemap: Array[Array] # Array[Array[DanceTile]]

func _enter_tree() -> void:
	GlobalContext.Register(self)

func _ready() -> void:
	for child in get_children():
		if child is DanceTile or child is DanceLabel:
			remove_child(child)
			child.queue_free()
		
	#GlobalContext.GetPlayer().set_grid_size(gridSize)
	GlobalContext.GetBoss().set_grid_size(gridSize)
	
	for x in range(maximumGridSize.x):
		tilemap.append([])
		for y in range(maximumGridSize.y):
			var scene := tile.instantiate() as DanceTile
			scene.name = "DanceTile-" + str(x) + "-" + str(y)
			scene.position = Vector3(x, 0, y)
			scene.gridX = x
			scene.gridY = y
			add_child(scene)
			tilemap[x].append(scene)
			
	const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	for x in range(maximumGridSize.x):
		var scene := Asset.Instantiate(DanceLabel) as DanceLabel
		scene.set_text(letters[x])
		scene.position = Vector3(x, 0, gridSize.y - 0.5)
		add_child(scene)
		
	for y in range(maximumGridSize.y):
		var scene := Asset.Instantiate(DanceLabel) as DanceLabel
		scene.set_text(str(y + 1))
		scene.position = Vector3(-0.5, 0, y)
		add_child(scene)
		
	GlobalContext.GetBoss().prep_patterns()
	SignalBus.OnFlushAllTimers.emit()
	GlobalContext.GetBoss().queue_patterns()
	AudioSystem.SortTimers()
				
	position -= Vector3(gridSize.x / 2.0 - 0.5, 0.0, gridSize.y / 2.0 - 0.5)
		
func _on_telegraph_tile(x: int, y: int) -> void:
	SignalBus.telegraphTile.emit(x, y)
	var bpmMod: float = AudioSystem.get_current_bpm() / 60.0
	await get_tree().create_timer(bpmMod).timeout
	SignalBus.explodeTile.emit(x, y)
	
func get_tile_at_position(pos: Vector2i) -> DanceTile:
	return tilemap[pos.x][pos.y]
	
func _process(delta: float) -> void:
	var livingTiles := 0
	var positionSum := Vector2(0.0, 0.0)
	for x in range(maximumGridSize.x):
		for y in range(maximumGridSize.y):
			var tile := get_tile_at_position(Vector2(x, y))
			if not tile or not tile.isAlive:
				continue
			
			livingTiles += 1
			positionSum.x += x
			positionSum.y += y
			
	var screenCenter := Vector3(positionSum.x / livingTiles, 0.0, positionSum.y / livingTiles)
	position = lerp(position, -screenCenter, delta / 2.0)
