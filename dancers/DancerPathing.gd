class_name DancerPathing extends Node

@onready var parent: Dancer = get_parent()

func NavigateTo(target: Vector2i) -> DanceFloorPathing.NavigationResult:
	return parent.danceFloor.pathing.Navigate(parent.GridPosition, target)

func NavigateWithoutCollisionTo(target: Vector2i) -> DanceFloorPathing.NavigationResult:
	var flags: Array[DanceFloorPathing.NavigationFlags] = [DanceFloorPathing.NavigationFlags.IgnoreCollision]
	return parent.danceFloor.pathing.Navigate(parent.GridPosition, target, flags)

func NavigateToPlayer(desiredOffsets: Array[Vector2i] = [Vector2i.ZERO]) -> DanceFloorPathing.NavigationResult:
	var player := GlobalContext.GetPlayer()
	if not player:
		return DanceFloorPathing.NavigationResult.new()

	var playerGridPosition := player.GridPosition
	var danceFloor := GlobalContext.GetDanceFloor()

	var result := DanceFloorPathing.NavigationResult.new()

	var directPath := NavigateWithoutCollisionTo(playerGridPosition)
	if directPath.pathFound:
		result.distance = directPath.distance
		result.flightDistance = directPath.flightDistance
	else:
		result.distance = 9999
		result.flightDistance = 9999

	for offset in desiredOffsets:
		if parent.GridPosition == playerGridPosition + offset:
			result.path = []
			result.pathFound = true
			return result

		var target := playerGridPosition + offset

		if not danceFloor.HasTile(target):
			continue

		var lastResult := NavigateTo(target)
		if lastResult.toDisabled:
			continue

		if lastResult.pathFound and (not result.pathFound or result.path.size() > lastResult.path.size()):
			# Avoid partial paths
			if lastResult.path[-1].x == target.x and lastResult.path[-1].y == target.y:
				result.pathFound = true
				result.path = lastResult.path

	if result.pathFound and result.path[0].x == parent.GridPosition.x and result.path[0].y == parent.GridPosition.y:
		result.path = result.path.slice(1)
	return result
