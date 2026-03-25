extends Node3D
class_name DanceTile

var gridX: int
var gridY: int

var explode: float = 0.0

var beatTimer: MusicTimer
var beatCounter: int = 0
var isAlive := true
var beatTween: Tween

func _ready() -> void:
	SignalBus.telegraphTile.connect(on_telegraph)
	SignalBus.explodeTile.connect(on_explode)
	SignalBus.clearAllTiles.connect(on_clear_all_tiles)
	SignalBus.OnRestoreTile.connect(on_restore_tile)
	SignalBus.OnDestroyTile.connect(on_destroy_tile)
	
	beatTimer = MusicTimer.Create()
	beatTimer.timeout.connect(on_beat)
	beatTimer.start_repeatable(0.0)

	
func on_beat(triggerBeat: int) -> void:
	if not isAlive:
		return
		
	beatCounter += 1
	beatTimer.start_repeatable(triggerBeat + 1)
	beatTween = create_tween()
	if beatCounter % 2 == 0:
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.05, 1.0, 1.0), 0.05)
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.0), 0.3)
	else:
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.05), 0.05)
		beatTween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.0), 0.3)

func on_telegraph(pos: Vector2i, delay: float) -> void:
	if pos.x != gridX or pos.y != gridY:
		return
		
	var driver := TileDriver.new()
	driver.Start(Vector2i(gridX, gridY), delay)
	add_child(driver)

func on_explode(x: int, y: int) -> void:
	if x != gridX or y != gridY:
		return
	
	explode = 1.0
	
func on_clear_all_tiles() -> void:
	explode = 0.0
	for child in get_children():
		if child is TileDriver:
			remove_child(child)
			child.queue_free()
			
func on_restore_tile(x: int, y: int) -> void:
	if x != gridX or y != gridY:
		return
	
	beatTimer.start_repeatable(roundi(GlobalContext.GetAudioAgent().get_position_beats()) + 1)
	isAlive = true
	create_tween().tween_property($MeshInstance3D, ^"scale", Vector3(1, 1, 1), 0.2)
	set_process(true)
	
func on_destroy_tile(x: int, y: int) -> void:
	if x != gridX or y != gridY:
		return
		
	beatTween.stop()
	isAlive = false
	create_tween().tween_property($MeshInstance3D, ^"scale", Vector3(0, 0, 0), 0.2)
	if is_inside_tree():
		await get_tree().create_timer(0.2).timeout
		if not isAlive:
			set_process(false)

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
