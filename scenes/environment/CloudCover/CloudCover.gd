@tool
extends MeshInstance3D

var _size = Vector3(1.0, 1.0, 1.0)
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var Size: Vector3:
	get: return _size
	set(value):
		_size = value
		self.mesh.size = _size
		_set_param("BoxHalfSize", value / 2.0)

@export_range(0.0, 50.0, 0.01) var Brightness: float = 1.0:
	set(value):
		Brightness = value
		_set_param("Brightness", value)

@export_range(0.0, 1.0, 0.01) var Coverage: float = 0.5:
	set(value):
		Coverage = value
		_set_param("Coverage", value)

@export_range(1.0, 3.0, 0.05) var CloudSharpness: float = 2.0:
	set(value):
		CloudSharpness = value
		_set_param("CloudSharpness", value)

@export_range(0.01, 3.0, 0.005) var StepSize: float = 0.025:
	set(value):
		StepSize = value
		_set_param("StepSize", value)

@export_range(0.1, 100.0, 0.1) var SamplerScale: float = 20.0:
	set(value):
		SamplerScale = value
		_set_param("SamplerScale", value)

@export_range(0.0, 2.0, 0.01) var WindStrength: float = 0.1:
	set(value):
		WindStrength = value
		_set_param("WindStrength", value)

@export_range(0.0, 5.0, 0.1) var LayerSpeedDifference: float = 1.0:
	set(value):
		LayerSpeedDifference = value
		_set_param("LayerSpeedDifference", value)

@export var WindDirection: Vector3 = Vector3(1.0, 0.0, 0.5):
	set(value):
		WindDirection = value
		_set_param("WindDirection", value)

func _set_param(param: String, value: Variant) -> void:
	var material = get_active_material(0) as ShaderMaterial
	if material:
		material.set_shader_parameter(param, value)

func _ready() -> void:
	if not Engine.is_editor_hint():
		set_process(false)

func _process(_delta: float) -> void:
	if _size != self.mesh.size:
		Size = self.mesh.size
