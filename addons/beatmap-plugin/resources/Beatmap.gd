@tool
class_name Beatmap extends Resource

signal stateUpdated(updateType: String)

## Speed multiplier for development
@export_range(0.5, 2.0, 0.02) var editorPlaybackSpeed: float = 1.0
## When enabled, the song's pitch is kept constant even while the speed changes
@export var editorPitchCompensation: bool = true
## How many parts does each beat consist of
@export_range(1, 8, 1) var editorBeatSubdivisions: float = 2

@export_category("Beatmap Setup")
## Song BPM for syncing
@export var bpm: int = 112
## Start offset for syncing, in beats
@export_range(-1, 1, 0.01) var beatmapOffset: float = 0.0
## Maximum grid size the pattern needs
@export var gridSize: Vector2i = Vector2i(4, 1)
## Chill beats to map patterns to
@export var audioFile: AudioStream = preload("res://addons/beatmap-plugin/audio/PlaceholderBeatmapLoop.wav")

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var patterns: Dictionary[String, Array] # Dictionary["x-y", SortedArray[BeatmapPatternData]]

enum PatternState {
	Idle = 0,
	Telegraph = 1,
	Destroyed = 2,
	Null = 100 # Explicit null value, not a valid state
}
