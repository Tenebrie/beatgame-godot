class_name BeatmapLoader extends Node

static func LoadAudio(resource: Beatmap) -> void:
	AudioSystem.RegisterBeatmap(resource)

static func LoadInitial(resource: Beatmap) -> void:
	for x in range(resource.gridSize.x):
		for y in range(resource.gridSize.y):
			var key := str(x) + "-" + str(y)
			if not resource.patterns.has(key) or resource.patterns[key].size() == 0:
				LoadDefaultPattern(x, y)
				continue

			var patterns := resource.patterns[key]
			for i in range(patterns.size()):
				var pattern: BeatmapPatternData = patterns[i]
				if pattern.startedAt > 0:
					continue
				var lookahead: BeatmapPatternData = patterns[i + 1] if patterns.size() > i + 1 else null
				LoadPattern(x, y, pattern, lookahead, resource)

static func Load(resource: Beatmap) -> void:
	for x in range(resource.gridSize.x):
		for y in range(resource.gridSize.y):
			var key := str(x) + "-" + str(y)
			if not resource.patterns.has(key):
				continue
			var patterns: Array = resource.patterns[key]
			LoadTile(x, y, patterns, resource)

static func LoadPattern(x: int, y: int, pattern: BeatmapPatternData, lookahead: BeatmapPatternData, _resource: Beatmap) -> void:
	if pattern.state == Beatmap.PatternState.Idle:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.startedAt).RestoreTile()
	if pattern.state == Beatmap.PatternState.Telegraph:
		var api := Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.finishedAt).Telegraph(pattern.finishedAt - pattern.startedAt)
		if not lookahead:
			api.DestroyTile()
	elif pattern.state == Beatmap.PatternState.Destroyed:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.startedAt).DestroyTile()

static func LoadDefaultPattern(x: int, y: int) -> void:
	Pattern.SingleIndexed(Vector2i(x, y)).DestroyTile()

static func LoadTile(x: int, y: int, patterns: Array, resource: Beatmap) -> void:
	for i in range(patterns.size()):
		var pattern: BeatmapPatternData = patterns[i]
		if pattern.startedAt == 0:
			continue
		var lookahead: BeatmapPatternData = patterns[i + 1] if patterns.size() > i + 1 else null
		LoadPattern(x, y, pattern, lookahead, resource)
