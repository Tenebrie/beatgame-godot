class_name BeatmapLoader extends Node

static func LoadInitial(resource: Beatmap) -> void:
	for x in range(resource.gridSize.x):
		for y in range(resource.gridSize.y):
			var key := str(x) + "-" + str(y)
			if not resource.patterns.has(key) or resource.patterns[key].size() == 0:
				continue
			var pattern: BeatmapPatternData = resource.patterns[key][0]
			if pattern.startedAt == 0:
				LoadPattern(x, y, pattern, resource)

static func Load(resource: Beatmap) -> void:
	for x in range(resource.gridSize.x):
		for y in range(resource.gridSize.y):
			var key := str(x) + "-" + str(y)
			if not resource.patterns.has(key):
				continue
			var patterns: Array = resource.patterns[key]
			LoadTile(x, y, patterns, resource)

static func LoadPattern(x: int, y: int, pattern: BeatmapPatternData, _resource: Beatmap) -> void:
	if pattern.state == Beatmap.PatternState.Idle:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.startedAt).RestoreTile()
	if pattern.state == Beatmap.PatternState.Telegraph:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.finishedAt).Telegraph(pattern.finishedAt - pattern.startedAt)
	elif pattern.state == Beatmap.PatternState.Destroyed:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.startedAt).DestroyTile()

static func LoadTile(x: int, y: int, patterns: Array, resource: Beatmap) -> void:
	for pattern: BeatmapPatternData in patterns:
		if pattern.startedAt == 0:
			continue
		LoadPattern(x, y, pattern, resource)
