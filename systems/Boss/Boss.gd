class_name Boss extends Node3D

func _enter_tree() -> void:
	GlobalContext.Register(self)

func set_grid_size(size: Vector2i) -> void:
	position = Vector3(size.x + 0.5, 0.0, (size.y - 1) / 2.0)

func queue_patterns() -> void:
	# === PHASE 1: "The Greeting" — slow diagonal sweep, learn the telegraph ===
	Pattern.Single("a1").Telegraph(1.5)
	Pattern.Single("b2").Telegraph(1.5).Delay(0.5)
	Pattern.Single("c3").Telegraph(1.5).Delay(1.0)
	Pattern.Single("d4").Telegraph(1.5).Delay(1.5)

	await Pattern.Void().Delay(3.5).Done()

	# Reverse diagonal
	Pattern.Single("d1").Telegraph(1.5)
	Pattern.Single("c2").Telegraph(1.5).Delay(0.5)
	Pattern.Single("b3").Telegraph(1.5).Delay(1.0)
	Pattern.Single("a4").Telegraph(1.5).Delay(1.5)

	await Pattern.Void().Delay(3.5).Done()

	# === PHASE 2: "The Squeeze" — rows close in from both sides ===
	Pattern.Row(1).Telegraph(1.0)
	Pattern.Row(4).Telegraph(1.0)

	await Pattern.Void().Delay(1.5).Done()

	Pattern.Row(2).Telegraph(0.8)
	Pattern.Row(3).Telegraph(0.8)

	await Pattern.Void().Delay(1.5).Done()

	# Now columns do the same — walls closing in
	Pattern.Column("a").Telegraph(1.0)
	Pattern.Column("d").Telegraph(1.0)

	await Pattern.Void().Delay(1.5).Done()

	Pattern.Column("b").Telegraph(0.8)
	Pattern.Column("c").Telegraph(0.8)

	await Pattern.Void().Delay(2.0).Done()

	# === PHASE 3: "The Cross" — safe corners, then safe center ===
	# Explode the cross (row 2-3, col b-c center + arms)
	Pattern.Row(2).Telegraph(1.2)
	Pattern.Row(3).Telegraph(1.2)
	Pattern.Single("b1").Telegraph(1.2)
	Pattern.Single("c1").Telegraph(1.2)
	Pattern.Single("b4").Telegraph(1.2)
	Pattern.Single("c4").Telegraph(1.2)

	await Pattern.Void().Delay(1.8).Done()

	# Now punish the corners where they just hid
	Pattern.Single("a1").Telegraph(0.8)
	Pattern.Single("a4").Telegraph(0.8)
	Pattern.Single("d1").Telegraph(0.8)
	Pattern.Single("d4").Telegraph(0.8)

	await Pattern.Void().Delay(1.5).Done()

	# === PHASE 4: "The Spiral" — clockwise sweep, tightening ===
	Pattern.Single("a1").Telegraph(0.8)
	Pattern.Single("b1").Telegraph(0.8).Delay(0.3)
	Pattern.Single("c1").Telegraph(0.8).Delay(0.6)
	Pattern.Single("d1").Telegraph(0.8).Delay(0.9)
	Pattern.Single("d2").Telegraph(0.8).Delay(1.2)
	Pattern.Single("d3").Telegraph(0.8).Delay(1.5)
	Pattern.Single("d4").Telegraph(0.8).Delay(1.8)
	Pattern.Single("c4").Telegraph(0.8).Delay(2.1)
	Pattern.Single("b4").Telegraph(0.8).Delay(2.4)
	Pattern.Single("a4").Telegraph(0.8).Delay(2.7)
	Pattern.Single("a3").Telegraph(0.8).Delay(3.0)
	Pattern.Single("a2").Telegraph(0.8).Delay(3.3)
	# Inner spiral
	Pattern.Single("b2").Telegraph(0.8).Delay(3.6)
	Pattern.Single("c2").Telegraph(0.8).Delay(3.9)
	Pattern.Single("c3").Telegraph(0.8).Delay(4.2)
	Pattern.Single("b3").Telegraph(0.8).Delay(4.5)

	await Pattern.Void().Delay(6.0).Done()

	# === PHASE 5: "The Rage" — fast checkerboard alternation ===
	# Black squares
	Pattern.Single("a1").Telegraph(0.6)
	Pattern.Single("a3").Telegraph(0.6)
	Pattern.Single("b2").Telegraph(0.6)
	Pattern.Single("b4").Telegraph(0.6)
	Pattern.Single("c1").Telegraph(0.6)
	Pattern.Single("c3").Telegraph(0.6)
	Pattern.Single("d2").Telegraph(0.6)
	Pattern.Single("d4").Telegraph(0.6)

	await Pattern.Void().Delay(0.9).Done()

	# White squares — if you dodged to them, now they blow
	Pattern.Single("a2").Telegraph(0.5)
	Pattern.Single("a4").Telegraph(0.5)
	Pattern.Single("b1").Telegraph(0.5)
	Pattern.Single("b3").Telegraph(0.5)
	Pattern.Single("c2").Telegraph(0.5)
	Pattern.Single("c4").Telegraph(0.5)
	Pattern.Single("d1").Telegraph(0.5)
	Pattern.Single("d3").Telegraph(0.5)

	await Pattern.Void().Delay(0.9).Done()

	# Double speed checkerboard — repeat twice
	Pattern.Single("a1").Telegraph(0.4)
	Pattern.Single("a3").Telegraph(0.4)
	Pattern.Single("b2").Telegraph(0.4)
	Pattern.Single("b4").Telegraph(0.4)
	Pattern.Single("c1").Telegraph(0.4)
	Pattern.Single("c3").Telegraph(0.4)
	Pattern.Single("d2").Telegraph(0.4)
	Pattern.Single("d4").Telegraph(0.4)

	await Pattern.Void().Delay(0.6).Done()

	Pattern.Single("a2").Telegraph(0.5)
	Pattern.Single("a4").Telegraph(0.5)
	Pattern.Single("b1").Telegraph(0.5)
	Pattern.Single("b3").Telegraph(0.5)
	Pattern.Single("c2").Telegraph(0.5)
	Pattern.Single("c4").Telegraph(0.5)
	Pattern.Single("d1").Telegraph(0.5)
	Pattern.Single("d3").Telegraph(0.5)

	await Pattern.Void().Delay(1.5).Done()

	# === PHASE 6: "The Finale" — everything at once, one safe tile ===
	# Leave only b3 safe
	Pattern.Row(1).Telegraph(1.5)
	Pattern.Row(2).Telegraph(1.5)
	Pattern.Row(4).Telegraph(1.5)
	Pattern.Single("a3").Telegraph(1.5)
	Pattern.Single("c3").Telegraph(1.5)
	Pattern.Single("d3").Telegraph(1.5)

	await Pattern.Void().Delay(2.5).Done()

	# Now blow b3 — nowhere is safe, but telegraph is the tell to move late
	Pattern.Single("b3").Telegraph(0.6)
	# Reopen the rest as safe by not targeting it
