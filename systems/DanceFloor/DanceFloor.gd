class_name DanceFloor extends Node3D

@export var tile: PackedScene

var gridSize := Vector2i(4, 4)

func _enter_tree() -> void:
	GlobalContext.Register(self)

func _ready() -> void:
	for child in get_children():
		if child is DanceTile:
			remove_child(child)
			child.queue_free()
		
	GlobalContext.GetPlayer().set_grid_size(gridSize)
	GlobalContext.GetBoss().set_grid_size(gridSize)
	#var secondsPassed := 0.0
	
	for x in range(gridSize.x):
		for y in range(gridSize.y):
			var scene := tile.instantiate() as DanceTile
			scene.name = "DanceTile-" + str(x) + "-" + str(y)
			scene.position = Vector3(x, 0, y)
			scene.gridX = x
			scene.gridY = y
			add_child(scene)
			
	const letters = 'abcdefghijklmnopqrstuvwxyz'
	for x in range(gridSize.x):
		var scene := Asset.Instantiate(DanceLabel) as DanceLabel
		scene.set_text(letters[x])
		scene.position = Vector3(x, 0, gridSize.y - 0.5)
		add_child(scene)
		
	for y in range(gridSize.x):
		var scene := Asset.Instantiate(DanceLabel) as DanceLabel
		scene.set_text(str(y + 1))
		scene.position = Vector3(-0.5, 0, y)
		add_child(scene)
		
	GlobalContext.GetBoss().queue_patterns()
			
	#for i in range(0, 4):
		#secondsPassed = 4.0 * i
		#for x in range(gridSize.x):
			#for y in range(gridSize.y / 2.0):
				#secondsPassed += 0.1
				#var currentSeconds := secondsPassed
				#var timer := get_tree().create_timer(currentSeconds)
				#timer.timeout.connect(_on_telegraph_tile.bind(x, y))
				#
		#secondsPassed = 4 * i + 2
		#for x in range(gridSize.x):
			#for y in range(gridSize.y / 2.0):
				#secondsPassed += 0.1
				#var currentSeconds := secondsPassed
				#var timer := get_tree().create_timer(currentSeconds)
				#timer.timeout.connect(_on_telegraph_tile.bind(x, y + gridSize.y / 2.0))
				
	position -= Vector3(gridSize.x / 2.0 - 0.5, 0.0, gridSize.y / 2.0 - 0.5)
		
func _on_telegraph_tile(x: int, y: int) -> void:
	SignalBus.telegraphTile.emit(x, y)
	await get_tree().create_timer(1.0).timeout
	SignalBus.explodeTile.emit(x, y)
