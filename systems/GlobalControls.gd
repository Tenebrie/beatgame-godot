extends Node
	
func _unhandled_input(rawEvent: InputEvent) -> void:
	var event := rawEvent as InputEventKey
	if not event:
		return
		
	if event.keycode == KEY_ESCAPE:
		get_tree().quit()
		
	if event.echo:
		return
		
	if event.pressed and event.keycode == KEY_9:
		#AudioSystem.fast_forward(floor(AudioSystem.get_current_beat() / 32.0) * 32.0 + 32.0)
		#await get_tree().create_timer(0.0).timeout
		#SignalBus.clearAllTiles.emit()
		Engine.time_scale = 16.0
		AudioSystem.set_playback_speed(16.0)
	elif not event.pressed and event.keycode == KEY_9:
		Engine.time_scale = 1.0
		AudioSystem.set_playback_speed(1.0)
		
	if not event.pressed:
		return
		
	if event.keycode == KEY_0:
		print(AudioSystem.get_current_beat())
	
