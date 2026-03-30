@tool
class_name Beatmap extends Resource

signal stateUpdated(updateType: String)

@export var bpm: int = 120
@export var audioFile: AudioStream
@export var gridSize: Vector2i = Vector2i(8, 8)
@export var patterns: Dictionary[String, Array] # Dictionary["x-y", SortedArray[BeatmapPatternData]]

enum PatternState {
	Idle = 0,
	Telegraph = 1,
	Destroyed = 2,
	Null = 100 # Explicit null value, not a valid state
}
