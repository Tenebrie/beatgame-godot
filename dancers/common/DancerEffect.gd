class_name DancerEffect extends Node3D

signal onInit
signal onCleanup

var parent: Dancer

func _ready() -> void:
	if get_parent() is not Dancer:
		return

	parent = get_parent()
	onInit.emit()

	if not Engine.is_editor_hint():
		parent.onDeath.connect(func() -> void:
			onCleanup.emit()
		)
