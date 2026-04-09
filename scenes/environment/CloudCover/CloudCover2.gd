@tool
extends MeshInstance3D

var _size = Vector3(1.0, 1.0, 1.0)
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var Size: Vector3:
	get: return _size
	set(value):
		_size = value
		self.mesh.size = _size
		_set_param("BoxHalfSize", value / 2.0)

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
