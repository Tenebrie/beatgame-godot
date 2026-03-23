class_name Boss extends Node3D

func _enter_tree() -> void:
	GlobalContext.Register(self)

func set_grid_size(size: Vector2i) -> void:
	position = Vector3(size.x + 0.5, 0.0, (size.y - 1) / 2.0)

func queue_patterns() -> void:
	#Pattern.Single("a1").Telegraph(1.0)
	#Pattern.Single("b2").Telegraph(2.0)
	#Pattern.Single("c3").Telegraph(3.0)
	#Pattern.Single("d4").Telegraph(4.0)
	Pattern.Row(1).Telegraph(1.0)
	Pattern.Row(2).Telegraph(2.0)
	Pattern.Column("a").Telegraph(1.0)
	Pattern.Column("b").Telegraph(1.0)
