class_name AudioAgent extends Node

const positionOffset := 0.0

func _enter_tree() -> void:
	GlobalContext.Register(self)

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	$AudioStreamPlayer.play()

func get_bpm() -> float:
	return 130.0
	
func get_position_beats() -> float:
	if not $AudioStreamPlayer.playing:
		return -1
		
	var offsetPos: float = $AudioStreamPlayer.get_playback_position() + positionOffset
	var precisePosition := offsetPos / 60.0 * get_bpm()
	return roundf(precisePosition * 8.0) / 8.0

func get_position_seconds() -> float:
	var player := $AudioStreamPlayer as AudioStreamPlayer
	return player.get_playback_position()
	
func get_duration_seconds() -> float:
	var player := $AudioStreamPlayer as AudioStreamPlayer
	return player.stream.get_length()

func fast_forward(beats: float) -> void:
	var current := get_position_beats()
	var target := current + beats - 4
	var targetSeconds := target * 60.0 / get_bpm()
	var player := $AudioStreamPlayer as AudioStreamPlayer
	player.seek(targetSeconds)
	
func set_speed(speed: float) -> void:
	var player := $AudioStreamPlayer as AudioStreamPlayer
	player.pitch_scale = speed
	
func set_volume(volume: float) -> void:
	var player := $AudioStreamPlayer as AudioStreamPlayer
	player.volume_linear = volume
