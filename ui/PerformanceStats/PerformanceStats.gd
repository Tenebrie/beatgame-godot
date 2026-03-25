extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var frametimeAccumulator: Array[float]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	frametimeAccumulator.append(delta)
	frametimeAccumulator = frametimeAccumulator.slice(0, 250)
	
	var totalFrametime := 0.0
	for i in range(frametimeAccumulator.size()):
		totalFrametime += frametimeAccumulator[i]
		
	$FramerateLabel.text = "FPS: " + str(roundi(1.0 / (totalFrametime / frametimeAccumulator.size())))
