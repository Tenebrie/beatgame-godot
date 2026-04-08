extends Node

var isPaused := false

func _unhandled_input(rawEvent: InputEvent) -> void:
	var event := rawEvent as InputEventKey
	if not event:
		return

	if event.pressed and event.keycode == KEY_ESCAPE:
		if OS.has_feature("editor"):
			get_tree().quit()
		else:
			isPaused = !isPaused
			var audioAgent := GlobalContext.GetAudioAgent()
			if isPaused:
				Engine.time_scale = 0.0
				audioAgent.Pause()
			else:
				Engine.time_scale = 1.0
				audioAgent.Resume()

	if event.echo:
		return

	if event.pressed and event.keycode == KEY_F11:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return

	#if event.pressed and event.keycode == KEY_8:
		#SignalBus.OnAdversaryDeath.emit()

	if event.pressed and event.keycode == KEY_9:
		Engine.time_scale = 16.0
		AudioSystem.set_playback_speed(16.0)
	elif not event.pressed and event.keycode == KEY_9:
		Engine.time_scale = 1.0
		AudioSystem.set_playback_speed(1.0)

	if not event.pressed:
		return
