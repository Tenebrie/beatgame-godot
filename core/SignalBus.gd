extends Node

signal telegraphTile(pos: Vector2i, delay: float)
signal explodeTile(x: int, y: int)
signal OnRestoreTile(x: int, y: int)
signal OnDestroyTile(x: int, y: int)
signal clearAllTiles()
signal clearTimersBefore(beat: int)

signal OnFlushAllTimers()
signal OnBasicBeat()
signal OnMinorBeat()
signal OnMajorBeat()
signal OnBeat(beat: float)
