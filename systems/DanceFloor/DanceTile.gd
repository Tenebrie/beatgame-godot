@tool
## Dynamically generated tile for DanceFloor
@icon("res://assets/icons/editor/Cross.svg")
class_name DanceTile extends Node3D

signal onDancerEnter(dancer: Dancer)
signal onDancerLeave(dancer: Dancer)

var GridPosition: Vector2i

var explode: float = 0.0

var beatTimer: MusicTimer
var isAlive := true
var beatTween: Tween

func _ready() -> void:
	GridPosition = Vector2i(roundi(position.x), roundi(position.z))
	SignalBus.telegraphTile.connect(_onTelegraph)
	SignalBus.explodeTile.connect(_onExplode)
	SignalBus.clearAllTiles.connect(_onClearAllTiles)
	SignalBus.OnRestoreTile.connect(_onRestoreTile)
	SignalBus.OnDestroyTile.connect(_onDestroyTile)
	SignalBus.OnDancerMove.connect(_onDancerMove)
	SignalBus.OnDancerDeath.connect(_onDancerDeath)

	beatTimer = MusicTimer.Create()
	beatTimer.timeout.connect(_onBeat)
	beatTimer.start_repeatable(0.0)

	SignalBus.ArenaReset.connect(func() -> void:
		beatTimer = MusicTimer.Create()
		beatTimer.timeout.connect(_onBeat)
		beatTimer.start_repeatable(0.0)
	)


func _onBeat(triggerBeat: int) -> void:
	if not isAlive:
		return

	beatTimer.start_repeatable(triggerBeat + 1)
	beatTween = create_tween()
	if triggerBeat % 2 == 0:
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.05, 1.0, 1.0), 0.05)
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.0), 0.3)
	else:
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.05), 0.05)
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.0), 0.3)

func _onTelegraph(pos: Vector2i, delay: float) -> void:
	if pos != GridPosition:
		return

	var driver := TileDriver.new()
	driver.Start(GridPosition, delay)
	add_child(driver)

func _onExplode(x: int, y: int) -> void:
	if x != GridPosition.x or y != GridPosition.y:
		return

	explode = 1.0

	var player := GlobalContext.GetPlayer()
	if not player or player.GridPosition != GridPosition:
		return

	if not is_inside_tree():
		print("Tile is not inside tree for some reason")
		return
	await get_tree().create_timer(0.02).timeout
	if player.GridPosition == GridPosition:
		player.DealDamage(1.0)

func _onClearAllTiles() -> void:
	explode = 0.0
	for child in get_children():
		if child is TileDriver:
			remove_child(child)
			child.queue_free()

func _onRestoreTile(x: int, y: int) -> void:
	if x != GridPosition.x or y != GridPosition.y:
		return

	beatTimer.start_repeatable(roundi(AudioSystem.get_current_beat()) + 1)
	isAlive = true
	create_tween().tween_property($MeshInstance3D, ^"scale", Vector3(1, 1, 1), 0.2)
	set_process(true)

func _onDestroyTile(x: int, y: int) -> void:
	if x != GridPosition.x or y != GridPosition.y:
		return

	beatTween.stop()
	isAlive = false
	create_tween().tween_property($MeshInstance3D, ^"scale", Vector3(0, 0, 0), 0.2)
	if is_inside_tree():
		await get_tree().create_timer(0.2).timeout
		if not isAlive:
			set_process(false)

var weightTween: Tween
func _onDancerMove(to: Vector2i, from: Vector2i, dancer: Dancer) -> void:
	if from == GridPosition:
		if weightTween:
			weightTween.kill()
		weightTween = create_tween()
		weightTween.tween_property(self, ^"position", Vector3(position.x, 0, position.z), 0.8).set_trans(Tween.TRANS_SPRING)
		onDancerLeave.emit(dancer)
	elif to == GridPosition:
		if weightTween:
			weightTween.kill()
		weightTween = create_tween()
		weightTween.tween_property(self, ^"position", Vector3(position.x, -0.07, position.z), 0.1)
		onDancerEnter.emit(dancer)

func _onDancerDeath(dancer: Dancer) -> void:
	if dancer.GridPosition == GridPosition:
		_onDancerMove(Vector2.ZERO, GridPosition, dancer)

func _process(delta: float) -> void:
	var telegraph := 0.0
	for child in get_children():
		var driver := child as TileDriver
		if driver:
			telegraph = maxf(telegraph, driver.telegraph)

	explode -= minf(explode, delta)

	var mat: ShaderMaterial = $MeshInstance3D.get_active_material(0)
	mat.set_shader_parameter("TelegraphProgress", telegraph)
	mat.set_shader_parameter("ImpactProgress", explode)
