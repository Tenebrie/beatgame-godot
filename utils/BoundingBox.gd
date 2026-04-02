class_name BoundingBox

var topLeft := Vector2i.ZERO
var bottomRight := Vector2i.ZERO

var position: Vector2i:
	get:
		return topLeft
var size: Vector2i:
	get:
		return bottomRight - topLeft

var width: int:
	get:
		return bottomRight.x - topLeft.x
var height: int:
	get:
		return bottomRight.y - topLeft.y

func _init(newTopLeft: Vector2i, newBottomRight: Vector2i) -> void:
	topLeft = newTopLeft
	bottomRight = newBottomRight

func AddPoint(point: Vector2i) -> BoundingBox:
	topLeft.x = mini(topLeft.x, point.x)
	topLeft.y = mini(topLeft.y, point.y)
	bottomRight.x = maxi(bottomRight.x, point.x)
	bottomRight.y = maxi(bottomRight.y, point.y)
	return self
