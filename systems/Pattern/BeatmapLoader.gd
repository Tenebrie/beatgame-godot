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

static func LoadAttack(resource: BeatmapAttack, transform: BeatmapTransform.Builder) -> void:
	#Pattern.Translate(transform.GetTranslation() - transform.GetOrigin())
	for x in range(resource.gridSize.x):
		for y in range(resource.gridSize.y):
			var key := str(x) + "-" + str(y)
			if not resource.patterns.has(key):
				continue
			var patterns: Array = resource.patterns[key]
			var transformedTile := transform.ApplyTransformations(Vector2i(x, y))
			LoadTile(transformedTile.x, transformedTile.y, patterns, resource)
	#Pattern.Translate(-transform.GetTranslation() + transform.GetOrigin())

static func LoadPattern(x: int, y: int, pattern: BeatmapPatternData, lookahead: BeatmapPatternData, _resource: Beatmap) -> void:
	var currentTime := maxf(0.0, AudioSystem.get_current_beat())
	if pattern.state == Beatmap.PatternState.Idle:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.startedAt + currentTime).RestoreTile()
	if pattern.state == Beatmap.PatternState.Telegraph:
		var api := Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.finishedAt + currentTime).Telegraph(pattern.finishedAt - pattern.startedAt)
		if not lookahead:
			api.DestroyTile()
	elif pattern.state == Beatmap.PatternState.Destroyed:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.startedAt + currentTime).DestroyTile()

static func LoadAttackPattern(x: int, y: int, pattern: BeatmapPatternData, _lookahead: BeatmapPatternData, _resource: Beatmap) -> void:
	if pattern.state == Beatmap.PatternState.Telegraph:
		Pattern.SingleIndexed(Vector2i(x, y)).Delay(pattern.finishedAt).Telegraph(pattern.finishedAt - pattern.startedAt)

static func LoadDefaultPattern(x: int, y: int) -> void:
	Pattern.SingleIndexed(Vector2i(x, y)).DestroyTile()

static func LoadTile(x: int, y: int, patterns: Array, resource: Beatmap) -> void:
	for i in range(patterns.size()):
		var pattern: BeatmapPatternData = patterns[i]
		if resource is not BeatmapAttack and pattern.startedAt == 0:
			continue
		var lookahead: BeatmapPatternData = patterns[i + 1] if patterns.size() > i + 1 else null
		if resource is BeatmapAttack:
			LoadAttackPattern(x, y, pattern, lookahead, resource)
		else:
			LoadPattern(x, y, pattern, lookahead, resource)
