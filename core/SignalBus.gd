@tool
extends Node

signal telegraphTile(pos: Vector2i, delay: float)
signal explodeTile(x: int, y: int)
signal OnRestoreTile(x: int, y: int)
signal OnDestroyTile(x: int, y: int)
signal clearAllTiles()
signal clearTimersBefore(beat: int)

signal OnFightBegin()
signal OnPlayerMove(to: Vector2i, from: Vector2i)
signal OnFlushAllTimers()
signal OnBasicBeat() # Each basic attack
signal OnMinorBeat(beat: float) # Each odd beat (1, 3, 5)
signal OnMajorBeat(beat: float) # Each even beat (0, 2, 4)
signal OnFullBeat(beat: float) # Each minor and major beat
signal OnAnyBeat(beat: float) # All registered beats, including fractionals
signal OnPlayerDeath()
signal OnAdversaryDeath()

signal DancerMove(to: Vector2i, from: Vector2i)

signal ArenaReset()

signal StartEmittingSurpriseParticles()
