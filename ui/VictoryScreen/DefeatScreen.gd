class_name DefeatScreen extends Control

func _ready() -> void:
	$CanvasLayer/Panel/Control/VBoxContainer/RestartButton.pressed.connect(
		func() -> void: 
			GameEndSystem.Restart()
			queue_free()
	)
