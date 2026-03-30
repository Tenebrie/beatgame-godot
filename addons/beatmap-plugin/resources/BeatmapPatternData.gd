@tool
class_name BeatmapPatternData extends Resource

@export var state: Beatmap.PatternState
@export var startedAt: float
@export var finishedAt: float

func _to_string() -> String:
	return "<Beatmap (%d) %f -> %f>"%[state, startedAt, finishedAt]
