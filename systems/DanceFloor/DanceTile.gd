extends Node3D
class_name DanceTile

var gridX: int
var gridY: int

var explode: float = 0.0

func _ready() -> void:
	SignalBus.telegraphTile.connect(on_telegraph)
	SignalBus.explodeTile.connect(on_explode)
	pass

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
	

func _process(delta: float) -> void:
	var telegraph := 0.0
	for child in get_children():
		if child is TileDriver:
			telegraph = max(telegraph, child.telegraph)
	
	explode -= min(explode, delta)
	
	var mat := $MeshInstance3D.get_active_material(0) as ShaderMaterial
	mat.set_shader_parameter("TelegraphProgress", telegraph)
	mat.set_shader_parameter("ImpactProgress", explode)
