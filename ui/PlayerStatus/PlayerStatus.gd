extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player := GlobalContext.GetPlayer()
	$PanelContainer/Control/ProgressBar.value = (1.0 - player.damageTaken / player.maximumHealth) * 100.0
