class_name BeatmapTransform

class Builder:
	var origin: Vector2i
	var translation: Vector2i
	var rotation: float
	var mirrorX: bool
	var mirrorY: bool

	func GetOrigin() -> Vector2i:
		return origin

	func GetTranslation() -> Vector2i:
		return translation

	func GetRotation() -> float:
		return rotation

	func SetOrigin(value: Vector2i) -> Builder:
		origin = value
		return self

	func Translate(delta: Vector2i) -> Builder:
		translation += delta
		return self

	func Rotate(delta: float) -> Builder:
		rotation += delta
		return self

	func MirrorX() -> Builder:
		mirrorX = !mirrorX
		return self

	func MirrorY() -> Builder:
		mirrorY = !mirrorY
		return self

	func ApplyTransformations(point: Vector2i) -> Vector2i:
		var p := point
		var o := origin

		# Mirror around (0,0)
		if mirrorX:
			p.x = -p.x
			o.x = -o.x
		if mirrorY:
			p.y = -p.y
			o.y = -o.y

		# Rotate around (0,0) (90° increments, CCW)
		var steps := wrapi(int(rotation / 90.0), 0, 4)
		for i in steps:
			p = Vector2i(-p.y, p.x)
			o = Vector2i(-o.y, o.x)

		return p - o + translation

static func FromOrigin(origin: Vector2i = Vector2i.ZERO) -> Builder:
	var transform := BeatmapTransform.Builder.new()
	transform.SetOrigin(origin)
	return transform
