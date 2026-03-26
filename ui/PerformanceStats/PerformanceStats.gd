extends Control

var frametimeAccumulator: Array[float]

func _process(delta: float) -> void:
	if Engine.time_scale == 0.0:
		return
		
	frametimeAccumulator.append(delta)
	if frametimeAccumulator.size() > 250:
		frametimeAccumulator.pop_front()
	
	var totalFrametime := 0.0
	for i in range(frametimeAccumulator.size()):
		totalFrametime += frametimeAccumulator[i]
		
	$FramerateLabel.text = "FPS: " + str(roundi(1.0 / (totalFrametime / frametimeAccumulator.size())))
