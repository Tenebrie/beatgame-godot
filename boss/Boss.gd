class_name Boss extends Node3D

var gridSize := Vector2i(1, 1)
var gridPosition := Vector2(1, 1)

func _enter_tree() -> void:
	GlobalContext.Register(self)

func set_grid_size(size: Vector2i) -> void:
	gridSize = size
	var targetPosition := Vector2(gridPosition.x * (size.x - gridSize.x), gridPosition.y * (size.y - gridSize.y) / 2.0)
	move_to(targetPosition)
	
func move_to_column_top(targetColumn: float) -> void:
	var topMostActiveTile := INF
	var tiles := GlobalContext.GetDanceFloor().tilemap
	for column in tiles:
		for tile: DanceTile in column:
			if tile.isAlive and tile.gridY < topMostActiveTile and absf(targetColumn - tile.gridX) <= 0.5:
				topMostActiveTile = tile.gridY
			
	move_to(Vector2(targetColumn, topMostActiveTile - 1))
	
func move_to_column_bottom(targetColumn: float) -> void:
	var bottomMostActiveTile := 0
	var tiles := GlobalContext.GetDanceFloor().tilemap
	for column in tiles:
		for tile: DanceTile in column:
			if tile.isAlive and tile.gridY > bottomMostActiveTile and absf(targetColumn - tile.gridX) <= 0.5:
				bottomMostActiveTile = tile.gridY
			
	move_to(Vector2(targetColumn, bottomMostActiveTile + 1))
	
func move_to_row_left(row: float) -> void:
	var leftMostActiveTile := INF
	var tiles := GlobalContext.GetDanceFloor().tilemap
	for column in tiles:
		for tile: DanceTile in column:
			if tile.isAlive and tile.gridX < leftMostActiveTile and absf(row - tile.gridY) - 1 <= 0.5:
				leftMostActiveTile = tile.gridX
			
	move_to(Vector2(leftMostActiveTile - 1, row - 1))
	
func move_to_row_right(row: float) -> void:
	var rightMostActiveTile := 0
	var tiles := GlobalContext.GetDanceFloor().tilemap
	for column in tiles:
		for tile: DanceTile in column:
			if tile.isAlive and tile.gridX > rightMostActiveTile and absf(row - tile.gridY) - 1 <= 0.5:
				rightMostActiveTile = tile.gridX
			
	move_to(Vector2(rightMostActiveTile + 1, row - 1))
	
func move_to(targetPos: Vector2) -> void:
	gridPosition = targetPos
	var row := gridPosition.x
	var column := gridPosition.y
	create_tween().tween_property(self, ^"position", Vector3(row, 0.0, column), 0.2)

func prep_patterns() -> void:
	Pattern.Rect("e1", "Z4").DestroyTile()
	SignalBus.OnFlushAllTimers.emit()
	Trigger.EnemyMoveToRowRight(2.5)

func queue_patterns() -> void:
	# Beat 0
	Trigger.EnemyMoveToRowRight(1).Delay(1.0)
	queue_intro_basic_attacks()
	Pattern.Advance(2)
	Pattern.Row(1).Telegraph(2).Delay(2.125)
	Pattern.Row(2).Telegraph(2).Delay(2.75)
	Pattern.Row(3).Telegraph(2).Delay(3.625)
	Pattern.Row(4).Telegraph(2).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(4)
	Pattern.Advance(2.0)
	Pattern.Row(4).Telegraph(2).Delay(2.125)
	Pattern.Row(3).Telegraph(2).Delay(2.75)
	Pattern.Row(2).Telegraph(2).Delay(3.625)
	Pattern.Row(1).Telegraph(2).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(1)
	Pattern.Advance(2.0)
	Pattern.Row(1).Telegraph(2).Delay(2.125)
	Pattern.Row(2).Telegraph(2).Delay(2.75)
	Pattern.Row(3).Telegraph(2).Delay(3.625)
	Pattern.Row(4).Telegraph(2).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(4)
	Pattern.Advance(2.0)
	Pattern.Row(4).Telegraph(2).Delay(2.125)
	Pattern.Row(3).Telegraph(2).Delay(2.75)
	Pattern.Row(2).Telegraph(2).Delay(3.625)
	Pattern.Row(1).Telegraph(2).Delay(4.75)
	Pattern.Advance(6.0)
	
	# Beat 32
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Advance(2.0)
	Pattern.Column("a").Telegraph(2).Delay(2.125)
	Pattern.Column("b").Telegraph(2).Delay(2.75)
	Pattern.Column("c").Telegraph(2).Delay(3.625)
	Pattern.Column("d").Telegraph(2).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Advance(2.0)
	Pattern.Column("d").Telegraph(2).Delay(2.125)
	Pattern.Column("c").Telegraph(2).Delay(2.75)
	Pattern.Column("b").Telegraph(2).Delay(3.625)
	Pattern.Column("a").Telegraph(2).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Advance(2.0)
	Pattern.Column("a").Telegraph(2).Delay(2.125)
	Pattern.Column("b").Telegraph(2).Delay(2.75)
	Pattern.Column("c").Telegraph(2).Delay(3.625)
	Pattern.Column("d").Telegraph(2).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks(0.0, true)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Advance(2.0)
	Pattern.Column("d").Telegraph(2).Delay(2.125)
	Pattern.Column("c").Telegraph(2).Delay(2.75)
	Pattern.Column("b").Telegraph(2).Delay(3.625)
	# Last beat skipped
	
	Trigger.EnemyMoveToRowRight(2).Delay(2)
	Pattern.Advance(6.0)
	
	# Beat 64
	queue_basic_attacks()
	
	full_boombox_pattern()
	
	Trigger.EnemyMoveToRowRight(3)
	Trigger.EnemyMoveToRowRight(2).Delay(2)
	Trigger.EnemyMoveToRowRight(3).Delay(4)
	Pattern.Advance(6.0)
	
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("a2").Telegraph(2).Delay(2.125)
	Pattern.Single("b2").Telegraph(2).Delay(2.75)
	Pattern.Single("c2").Telegraph(2).Delay(3.625)
	Pattern.Single("d2").Telegraph(2).Delay(4.75)
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(3)
	queue_basic_attacks()
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("d3").Telegraph(2).Delay(2.125)
	Pattern.Single("c3").Telegraph(2).Delay(2.75)
	Pattern.Single("b3").Telegraph(2).Delay(3.625)
	Pattern.Single("a3").Telegraph(2).Delay(4.75)
	Pattern.Advance(4.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Single("a2").Telegraph(2).Delay(2.125)
	Pattern.Single("b2").Telegraph(2).Delay(2.75)
	Pattern.Single("c2").Telegraph(2).Delay(3.625)
	Pattern.Single("d2").Telegraph(2).Delay(4.75)
	Pattern.Advance(2.0)
	queue_basic_attacks()
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("d3").Telegraph(2).Delay(2.125)
	Pattern.Single("c3").Telegraph(2).Delay(2.75)
	Pattern.Single("b3").Telegraph(2).Delay(3.625)
	Pattern.Single("a3").Telegraph(2).Delay(4.75)
	Pattern.Advance(4.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Single("a2").Telegraph(2).Delay(2.125)
	Pattern.Single("b2").Telegraph(2).Delay(2.75)
	Pattern.Single("c2").Telegraph(2).Delay(3.625)
	Pattern.Single("d2").Telegraph(2).Delay(4.75)
	Pattern.Advance(2.0)
	queue_basic_attacks()
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("d3").Telegraph(2).Delay(2.125)
	Pattern.Single("c3").Telegraph(2).Delay(2.75)
	Pattern.Single("b3").Telegraph(2).Delay(3.625)
	Pattern.Single("a3").Telegraph(2).Delay(4.75)
	Pattern.Advance(4.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	
	# Beat 96
	Trigger.EnemyMoveToRowRight(2.5)
	
	var startingWingDirection := randi() % 2
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(8.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(val)
	)
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(16.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(1 - val)
	)
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(24.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(val)
	)
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(32.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(1 - val)
	)
	
	queue_basic_attacks()
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	queue_basic_attacks()
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	queue_basic_attacks()
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	queue_basic_attacks()
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	
	Pattern.Column("a").Telegraph(2.0).Delay(2.125)
	Pattern.Column("d").Telegraph(2.0).Delay(2.75)
	Pattern.Row(1).Telegraph(2.0).Delay(3.625)
	Pattern.Row(4).Telegraph(2.0).Delay(4.75)
	
	Pattern.Advance(6.0)
	
	# Beat 128
	Pattern.Row(2).Telegraph(2.0)
	Pattern.Row(3).Telegraph(2.0)
	for i in range(8):
		queue_basic_attacks(i * 8)
	
	for i in range(1, 9):
		Pattern.PlayerPosition().Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(1, 0)).Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(0, 1)).Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(-1, 0)).Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(0, -1)).Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(1, 1)).Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(-1, -1)).Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(1, -1)).Telegraph(4).Delay(i * 8)
		Pattern.PlayerPosition(Vector2(-1, 1)).Telegraph(4).Delay(i * 8)
		
	Pattern.Advance(4)
	for i in range(0, 7):
		Trigger.EnemyMoveToPlayerRow()
		Pattern.Cast($LineBurst).Delay(8.0).Telegraph(4.0)
		Pattern.Advance(8)
		
	Pattern.Advance(4)
	
	# Beat 192 -> Arena swap
	#Pattern.StartHere()
	Trigger.Execute(func() -> void: GlobalContext.GetPlayer().SetBasicAttackEffectEmitting(false))
	
	Trigger.EnemyMoveToRowRight(2.5)
	Pattern.Advance(6.0)
	var firstWing := $WingSwipeLeft
	var secondWing := $WingSwipeRight
	var tileOffset := -0.5
	if randi() % 2 == 0:
		firstWing = $WingSwipeRight
		secondWing = $WingSwipeLeft
		tileOffset = 0.5
		
	Pattern.Cast($LineBurst).Telegraph(23.5).Delay(23.5).BeforeTelegraph(func() -> void: $LineBurst.position = Vector3(0, 0, tileOffset))
		
	Pattern.Cast(firstWing).Telegraph(16.5).Delay(24.5)
	Pattern.Cast(secondWing).Telegraph(10.0).Delay(25.5)
	
	Pattern.Single("a1").Telegraph(6.0).DestroyTile()
	Pattern.Single("a4").Telegraph(6.0).DestroyTile()
	
	Pattern.Single("a2").Telegraph(6.0).Delay(8).DestroyTile()
	Pattern.Single("a3").Telegraph(6.0).Delay(8).DestroyTile()
	Pattern.Single("b1").Telegraph(6.0).Delay(8).DestroyTile()
	Pattern.Single("b4").Telegraph(6.0).Delay(8).DestroyTile()
	
	Pattern.Single("b2").Telegraph(6.0).Delay(16).DestroyTile()
	Pattern.Single("b3").Telegraph(6.0).Delay(16).DestroyTile()
	Pattern.Single("c1").Telegraph(6.0).Delay(16).DestroyTile()
	Pattern.Single("c4").Telegraph(6.0).Delay(16).DestroyTile()
	
	Pattern.Single("c2").Telegraph(6.0).Delay(24).DestroyTile()
	Pattern.Single("c3").Telegraph(6.0).Delay(24).DestroyTile()
	Pattern.Single("d1").Telegraph(6.0).Delay(24).DestroyTile()
	Pattern.Single("d4").Telegraph(6.0).Delay(24).DestroyTile()
	
	Pattern.Advance(8.0)
	
	Pattern.Advance(18.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Cast($LineBurst).Telegraph(4).Delay(5).BeforeTelegraph(func() -> void: $LineBurst.position = Vector3(0, 0, 0))
	Pattern.Advance(6.0)
	
	Pattern.Single("e2").RestoreTile()
	Pattern.Single("f2").RestoreTile()
	
	Pattern.Single("f3").RestoreTile().Delay(8.0)
	Pattern.Single("g3").RestoreTile().Delay(8.0)
	
	Pattern.Single("h3").RestoreTile().Delay(16.0)
	Pattern.Single("h2").RestoreTile().Delay(16.0)
	Pattern.Single("h1").RestoreTile().Delay(16.0)
	
	Pattern.Single("i1").RestoreTile().Delay(24.0)
	Pattern.Single("j1").RestoreTile().Delay(24.0)
	
	Trigger.EnemyMoveToColumnTop("d")
	Pattern.Cast($LineBurst).Telegraph(6).Delay(8).BeforeTelegraph(func() -> void: 
		$LineBurst.rotation_degrees = Vector3(0.0, 90, 0.0)
		$LineBurst.position = Vector3(0, 0, 0)
	)
	Trigger.EnemyMoveToRowLeft(2).Delay(8.0)
	Pattern.Cast($LineBurst).Telegraph(6).Delay(16).BeforeTelegraph(func() -> void: 
		$LineBurst.rotation_degrees = Vector3(0.0, 180, 0.0)
	)
	Trigger.EnemyMoveToRowRight(3).Delay(16)
	Pattern.Cast($LineBurst).Telegraph(6).Delay(24).BeforeTelegraph(func() -> void: 
		$LineBurst.rotation_degrees = Vector3(0.0, 0, 0.0)
	)
	Trigger.EnemyMove(Vector2(8.5, 1.5)).Delay(25.0)
	
	Pattern.Advance(24.0)
	for i in range(8):
		queue_basic_attacks(i * 8 + 2)
		
	Trigger.Execute(func() -> void:
		var player := GlobalContext.GetPlayer()
		player.SetBasicAttackEffectEmitting(true)
		player.SetBasicAttackTargetingBoss(true)
	)
	
	Trigger.EnemyMove(Vector2(8.5, 1)).Delay(5.0)
	Trigger.EnemyMove(Vector2(7.5, 1)).Delay(9.0)
	Trigger.EnemyMove(Vector2(7.5, 1.5)).Delay(13.0)
	Trigger.EnemyMove(Vector2(8, 2)).Delay(62.0)
	Trigger.EnemyMove(Vector2(8, 1)).Delay(64.0)
	Trigger.EnemyMoveToRowRight(2.5).Delay(65.0)
	Trigger.EnemyMoveToRowRight(1).Delay(66.0)
	
	Pattern.Single("d3").DestroyTile().Delay(2).Telegraph(4.0)
	Pattern.Single("d2").DestroyTile().Delay(3).Telegraph(4.0)
	Pattern.Single("e2").DestroyTile().Delay(4).Telegraph(4.0)
	Pattern.Single("f2").DestroyTile().Delay(5).Telegraph(4.0)
	Pattern.Single("f3").DestroyTile().Delay(6).Telegraph(4.0)
	Pattern.Single("g3").DestroyTile().Delay(7).Telegraph(4.0)
	Pattern.Single("h3").DestroyTile().Delay(8).Telegraph(4.0)
	Pattern.Single("h2").DestroyTile().Delay(9).Telegraph(4.0)
	Pattern.Single("h1").DestroyTile().Delay(10).Telegraph(4.0)
	Pattern.Single("i1").DestroyTile().Delay(11).Telegraph(4.0)
	Pattern.Single("j1").DestroyTile().Delay(12).Telegraph(4.0)
	Pattern.Single("k1").DestroyTile().Delay(13).Telegraph(4.0)
	Pattern.Single("k2").DestroyTile().Delay(14).Telegraph(4.0)
	Pattern.Single("k3").DestroyTile().Delay(15).Telegraph(4.0)
	Pattern.Single("j3").DestroyTile().Delay(16).Telegraph(4.0)
	
	Pattern.Single("k1").RestoreTile().Delay(2)
	Pattern.Single("k2").RestoreTile().Delay(3)
	Pattern.Single("k3").RestoreTile().Delay(4)
	Pattern.Single("j3").RestoreTile().Delay(5)
	Pattern.Single("j4").RestoreTile().Delay(6)
	Pattern.Single("i4").RestoreTile().Delay(7)
	Pattern.Single("h4").RestoreTile().Delay(8)
	Pattern.Single("g4").RestoreTile().Delay(9)
	Pattern.Single("g3").RestoreTile().Delay(10)
	Pattern.Single("g2").RestoreTile().Delay(11)
	Pattern.Single("g1").RestoreTile().Delay(12)
	Pattern.Single("h1").RestoreTile().Delay(13)
	Pattern.Single("i1").RestoreTile().Delay(14)
	Pattern.Single("j1").RestoreTile().Delay(15)
	Pattern.Single("j2").RestoreTile().Delay(16)
	
	Pattern.Advance(17)
	
	for i in range(3):
		Pattern.Single("j4").DestroyTile().Delay(i * 12).Telegraph(4.0)
		Pattern.Single("i4").DestroyTile().Delay(i * 12 + 1).Telegraph(4.0)
		Pattern.Single("h4").DestroyTile().Delay(i * 12 + 2).Telegraph(4.0)
		Pattern.Single("g4").DestroyTile().Delay(i * 12 + 3).Telegraph(4.0)
		Pattern.Single("g3").DestroyTile().Delay(i * 12 + 4).Telegraph(4.0)
		Pattern.Single("g2").DestroyTile().Delay(i * 12 + 5).Telegraph(4.0)
		Pattern.Single("g1").DestroyTile().Delay(i * 12 + 6).Telegraph(4.0)
		Pattern.Single("h1").DestroyTile().Delay(i * 12 + 7).Telegraph(4.0)
		Pattern.Single("i1").DestroyTile().Delay(i * 12 + 8).Telegraph(4.0)
		Pattern.Single("j1").DestroyTile().Delay(i * 12 + 9).Telegraph(4.0)
		Pattern.Single("j2").DestroyTile().Delay(i * 12 + 10).Telegraph(4.0)
		Pattern.Single("j3").DestroyTile().Delay(i * 12 + 11).Telegraph(4.0)
		
		Pattern.Single("j3").RestoreTile().Delay(i * 12)
		Pattern.Single("j4").RestoreTile().Delay(i * 12 + 1)
		Pattern.Single("i4").RestoreTile().Delay(i * 12 + 2)
		Pattern.Single("h4").RestoreTile().Delay(i * 12 + 3)
		Pattern.Single("g4").RestoreTile().Delay(i * 12 + 4)
		Pattern.Single("g3").RestoreTile().Delay(i * 12 + 5)
		Pattern.Single("g2").RestoreTile().Delay(i * 12 + 6)
		Pattern.Single("g1").RestoreTile().Delay(i * 12 + 7)
		Pattern.Single("h1").RestoreTile().Delay(i * 12 + 8)
		Pattern.Single("i1").RestoreTile().Delay(i * 12 + 9)
		Pattern.Single("j1").RestoreTile().Delay(i * 12 + 10)
		Pattern.Single("j2").RestoreTile().Delay(i * 12 + 11)
		
	Pattern.Advance(36)
	
	Pattern.Single("j4").DestroyTile().Delay(0).Telegraph(4.0)
	Pattern.Single("i4").DestroyTile().Delay(1).Telegraph(4.0)
	Pattern.Single("h4").DestroyTile().Delay(2).Telegraph(4.0)
	Pattern.Single("g4").DestroyTile().Delay(3).Telegraph(4.0)
	Pattern.Single("g3").DestroyTile().Delay(4).Telegraph(4.0)
	Pattern.Single("g2").DestroyTile().Delay(5).Telegraph(4.0)
	Pattern.Single("g1").DestroyTile().Delay(6).Telegraph(4.0)
	Pattern.Single("h1").DestroyTile().Delay(7).Telegraph(4.0)
	
	Pattern.Single("j3").RestoreTile()
	Pattern.Single("j4").RestoreTile().Delay(1)
	Pattern.Single("i4").RestoreTile().Delay(2)
	Pattern.Single("h4").RestoreTile().Delay(3)
	Pattern.Single("g4").RestoreTile().Delay(4)
	Pattern.Single("g3").RestoreTile().Delay(5)
	Pattern.Single("g2").RestoreTile().Delay(6)
	Pattern.Single("g1").RestoreTile().Delay(7)
	Pattern.Single("h1").RestoreTile().Delay(8)
	Pattern.Single("h2").RestoreTile().Delay(9)
	Pattern.Single("h3").RestoreTile().Delay(10)
	Pattern.Single("i3").RestoreTile().Delay(11)
	Pattern.Single("i2").RestoreTile().Delay(12)
	
	Pattern.Advance(13)
	Pattern.Translate(Vector2i(6, 0))
	
	# Beat 320 -> Repeat intro
	Trigger.Execute(func() -> void:
		var player := GlobalContext.GetPlayer()
		player.SetBasicAttackTargetingBoss(false)
	)
	queue_intro_basic_attacks()
	Pattern.Advance(2)
	Pattern.Row(1).Telegraph(4).Delay(2.125)
	Pattern.Row(2).Telegraph(4).Delay(2.75)
	Pattern.Row(3).Telegraph(4).Delay(3.625)
	Pattern.Row(4).Telegraph(4).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(4).Delay(-1)
	Pattern.Advance(2.0)
	Pattern.Row(4).Telegraph(4).Delay(2.125)
	Pattern.Row(3).Telegraph(4).Delay(2.75)
	Pattern.Row(2).Telegraph(4).Delay(3.625)
	Pattern.Row(1).Telegraph(4).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(1).Delay(-1)
	Pattern.Advance(2.0)
	Pattern.Row(1).Telegraph(4).Delay(2.125)
	Pattern.Row(2).Telegraph(4).Delay(2.75)
	Pattern.Row(3).Telegraph(4).Delay(3.625)
	Pattern.Row(4).Telegraph(4).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(4).Delay(-1)
	Pattern.Advance(2.0)
	Pattern.Row(4).Telegraph(4).Delay(2.125)
	Pattern.Row(3).Telegraph(4).Delay(2.75)
	Pattern.Row(2).Telegraph(4).Delay(3.625)
	Pattern.Row(1).Telegraph(4).Delay(4.75)
	Pattern.Advance(6.0)
	
	# Beat 352
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Advance(2.0)
	Pattern.Column("a").Telegraph(4).Delay(2.125)
	Pattern.Column("b").Telegraph(4).Delay(2.75)
	Pattern.Column("c").Telegraph(4).Delay(3.625)
	Pattern.Column("d").Telegraph(4).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Advance(2.0)
	Pattern.Column("d").Telegraph(4).Delay(2.125)
	Pattern.Column("c").Telegraph(4).Delay(2.75)
	Pattern.Column("b").Telegraph(4).Delay(3.625)
	Pattern.Column("a").Telegraph(4).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks()
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Advance(2.0)
	Pattern.Column("a").Telegraph(4).Delay(2.125)
	Pattern.Column("b").Telegraph(4).Delay(2.75)
	Pattern.Column("c").Telegraph(4).Delay(3.625)
	Pattern.Column("d").Telegraph(4).Delay(4.75)
	Pattern.Advance(6.0)
	queue_intro_basic_attacks(0.0, true)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Advance(2.0)
	Pattern.Column("d").Telegraph(4).Delay(2.125)
	Pattern.Column("c").Telegraph(4).Delay(2.75)
	Pattern.Column("b").Telegraph(4).Delay(3.625)
	# Last beat skipped
	
	Pattern.Advance(6.0)
	for i in range(8):
		queue_basic_attacks(i * 16)
		queue_basic_attacks(i * 16 + 8)
		boombox_pattern_eight_beats(i * 16)
		central_boombox_pattern_eight_beats(i * 16 + 8)
		
	
	for i in range(4):
		Trigger.EnemyMoveToRowRight(2).Delay(0.0)
		Pattern.Cast($WingSwipeLeft).Delay(8.0).Telegraph(7.0)
		Trigger.EnemyMoveToRowRight(2.5).Delay(8.0)
		Pattern.Cast($WingSwipeRight).Delay(16.0).Telegraph(6.0)
		Trigger.EnemyMoveToRowRight(2.5).Delay(16.0)
		Pattern.Cast($LineBurst).Delay(24.0).Telegraph(7.0)
		var wing := $WingSwipeLeft if randi() % 2 == 0 else $WingSwipeRight
		Pattern.Cast($WingSwipe).Delay(32.0).Telegraph(7.0).BeforeTelegraph(
			func() -> void:
				if GlobalContext.GetPlayer().grid_pos.y <= 1:
					$WingSwipe.set_direction(1)
				else:
					$WingSwipe.set_direction(0)
		)
		Pattern.Advance(32)
	
	# Beat 512
	
	for i in range(8):
		queue_intro_basic_attacks(i * 8)
	
	for outerLoop in range(2):
		var rainTiles: Array[String]
		for x in range(4):
			for y in range(4):
				var tile := Pattern.letters[x] + str(y + 1)
				rainTiles.append(tile)
				
		rainTiles.shuffle()
		
		for loop in range(7):
			for i in range(rainTiles.size()):
				Pattern.Single(rainTiles[i]).Telegraph(2.0).Delay(i * 0.25)
			Pattern.Advance(4)
		Pattern.Advance(4)
			
	for i in range(7):
		boombox_pattern_eight_beats(i * 8)
	
	for i in range(7):
		queue_basic_attacks(i * 8)
		
	# Repeat earlier part
	Trigger.EnemyMoveToRowRight(3)
	Trigger.EnemyMoveToRowRight(2).Delay(2)
	Trigger.EnemyMoveToRowRight(3).Delay(4)
	Pattern.Advance(6.0)
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("a2").Telegraph(2).Delay(2.125)
	Pattern.Single("b2").Telegraph(2).Delay(2.75)
	Pattern.Single("c2").Telegraph(2).Delay(3.625)
	Pattern.Single("d2").Telegraph(2).Delay(4.75)
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("d3").Telegraph(2).Delay(2.125)
	Pattern.Single("c3").Telegraph(2).Delay(2.75)
	Pattern.Single("b3").Telegraph(2).Delay(3.625)
	Pattern.Single("a3").Telegraph(2).Delay(4.75)
	Pattern.Advance(4.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Single("a2").Telegraph(2).Delay(2.125)
	Pattern.Single("b2").Telegraph(2).Delay(2.75)
	Pattern.Single("c2").Telegraph(2).Delay(3.625)
	Pattern.Single("d2").Telegraph(2).Delay(4.75)
	Pattern.Advance(2.0)
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("d3").Telegraph(2).Delay(2.125)
	Pattern.Single("c3").Telegraph(2).Delay(2.75)
	Pattern.Single("b3").Telegraph(2).Delay(3.625)
	Pattern.Single("a3").Telegraph(2).Delay(4.75)
	Pattern.Advance(4.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Single("a2").Telegraph(2).Delay(2.125)
	Pattern.Single("b2").Telegraph(2).Delay(2.75)
	Pattern.Single("c2").Telegraph(2).Delay(3.625)
	Pattern.Single("d2").Telegraph(2).Delay(4.75)
	Pattern.Advance(2.0)
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(2)
	Pattern.Single("d3").Telegraph(2).Delay(2.125)
	Pattern.Single("c3").Telegraph(2).Delay(2.75)
	Pattern.Single("b3").Telegraph(2).Delay(3.625)
	Pattern.Single("a3").Telegraph(2).Delay(4.75)
	Pattern.Advance(4.0)
	Trigger.EnemyMoveToRowRight(3)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Trigger.EnemyMoveToRowRight(2.5)
	
	startingWingDirection = randi() % 2
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(8.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(val)
	)
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(16.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(1 - val)
	)
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(24.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(val)
	)
	Pattern.Cast($WingSwipe).Telegraph(6.0).Delay(32.0).BeforeTelegraph(
		func(val := startingWingDirection) -> void:
			$WingSwipe.set_direction(1 - val)
	)
	
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("b2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("b3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	Pattern.Single("c2").Telegraph(2.0).Delay(2.0)
	Pattern.Single("c3").Telegraph(2.0).Delay(2.0)
	Pattern.Single("a2").Telegraph(2.0).Delay(3.0)
	Pattern.Single("a3").Telegraph(2.0).Delay(3.0)
	Pattern.Advance(2.0)
	
	Pattern.Advance(2.0)
	
	# Beat 632
	Pattern.Single("a2").Telegraph(2.0).Delay(0.125)
	Pattern.Single("a3").Telegraph(2.0).Delay(0.125)
	Pattern.Single("d2").Telegraph(2.0).Delay(0.125)
	Pattern.Single("d3").Telegraph(2.0).Delay(0.125)
	
	Pattern.Rect("b2", "c3").Telegraph(2.0).Delay(0.75)
	Pattern.Row(1).Telegraph(2.0).Delay(1.625)
	Pattern.Row(4).Telegraph(2.0).Delay(1.625)
	Pattern.Single("a2").Telegraph(2.0).Delay(2.75)
	Pattern.Single("a3").Telegraph(2.0).Delay(2.75)
	Pattern.Single("d2").Telegraph(2.0).Delay(2.75)
	Pattern.Single("d3").Telegraph(2.0).Delay(2.75)
	
	Pattern.Single("b1").Telegraph(2.0).Delay(3.5)
	Pattern.Single("c1").Telegraph(2.0).Delay(3.5)
	Pattern.Single("b4").Telegraph(2.0).Delay(3.5)
	Pattern.Single("c4").Telegraph(2.0).Delay(3.5)
	Pattern.Advance(4.0)
	Pattern.Column("a").Telegraph(2.0).Delay(0.125)
	Pattern.Column("d").Telegraph(2.0).Delay(0.125)
	
	Pattern.Rect("b2", "c3").Telegraph(2.0).Delay(0.75)
	Pattern.Row(1).Telegraph(2.0).Delay(1.625)
	Pattern.Row(4).Telegraph(2.0).Delay(1.625)
	
	Pattern.Advance(4)
	for i in range(7):
		boombox_pattern_eight_beats(i * 8)
		
	for i in range(7):
		queue_basic_attacks(i * 8)
		
	Trigger.EnemyMoveToRowRight(2.5).Delay(-1)
	for i in range(7):
		Pattern.Cast($LineBurst).Delay(i * 8 + 6).Telegraph(6.0)
	
	Pattern.Advance(56)
	
	Pattern.Column("d").Telegraph(2).Delay(0.125)
	Pattern.Column("c").Telegraph(2).Delay(0.75)
	Pattern.Column("b").Telegraph(2).Delay(1.625)
	Pattern.Column("a").Telegraph(2).Delay(2.75)
	Pattern.Advance(4.0)
	Pattern.Column("a").Telegraph(2).Delay(-0.125)
	Pattern.Column("b").Telegraph(2).Delay(0.125)
	Pattern.Column("c").Telegraph(2).Delay(0.75)
	Pattern.Column("d").Telegraph(2).Delay(1.625)
	
	Trigger.EnemyMoveToRowRight(2.5)
	
	Pattern.Advance(4)
	for i in range(4):
		queue_basic_attacks(i * 8.0)
	for i in range(8):
		Pattern.Cast($LineBurst).Delay(i * 4)
	for i in range(4):
		boombox_pattern_eight_beats(i * 8)
	
func queue_intro_basic_attacks(delay: float = 0.0, skip_last: bool = false) -> void:
	Trigger.BasicAttack().Delay(0.125 + delay)
	Trigger.BasicAttack().Delay(0.75 + delay)
	Trigger.BasicAttack().Delay(1.625 + delay)
	Trigger.BasicAttack().Delay(2.75 + delay)
	Trigger.BasicAttack().Delay(3.625 + delay)
	Trigger.BasicAttack().Delay(4.25 + delay)
	Trigger.BasicAttack().Delay(5.0 + delay)
	Trigger.BasicAttack().Delay(5.625 + delay)
	if not skip_last:
		Trigger.BasicAttack().Delay(6.75 + delay)
		Trigger.BasicAttack().Delay(7.75 + delay)
		
func queue_basic_attacks(delay: float = 0.0) -> void:
	for i in range(8):
		Trigger.BasicAttack().Delay(i + delay)
	
func full_boombox_pattern() -> void:
	boombox_pattern_eight_beats(0)
	boombox_pattern_eight_beats(8)
	boombox_pattern_eight_beats(16)
	boombox_pattern_eight_beats(24)
	boombox_pattern_eight_beats(32)
	boombox_pattern_eight_beats(40)
	boombox_pattern_eight_beats(48)
	Pattern.Single("a1").Telegraph(2).Delay(56)
	Pattern.Single("a4").Telegraph(2).Delay(56)
	Pattern.Single("d1").Telegraph(2).Delay(56)
	Pattern.Single("d4").Telegraph(2).Delay(56)
	Pattern.Single("b1").Telegraph(2).Delay(57)
	Pattern.Single("c1").Telegraph(2).Delay(57)
	Pattern.Single("b4").Telegraph(2).Delay(57)
	Pattern.Single("c4").Telegraph(2).Delay(57)
	Pattern.Single("a1").Telegraph(2).Delay(58)
	Pattern.Single("a4").Telegraph(2).Delay(58)
	Pattern.Single("d1").Telegraph(2).Delay(58)
	Pattern.Single("d4").Telegraph(2).Delay(58)
	Pattern.Single("b1").Telegraph(2).Delay(59)
	Pattern.Single("c1").Telegraph(2).Delay(59)
	Pattern.Single("b4").Telegraph(2).Delay(59)
	Pattern.Single("c4").Telegraph(2).Delay(59)
	
	for i in range(8):
		boombox_pattern_eight_beats(64 + i * 8)

func boombox_pattern_eight_beats(delay: int) -> void:
	Pattern.Single("a1").Telegraph(2).Delay(0 + delay)
	Pattern.Single("a4").Telegraph(2).Delay(0 + delay)
	Pattern.Single("d1").Telegraph(2).Delay(0 + delay)
	Pattern.Single("d4").Telegraph(2).Delay(0 + delay)
	Pattern.Single("b1").Telegraph(2).Delay(1 + delay)
	Pattern.Single("c1").Telegraph(2).Delay(1 + delay)
	Pattern.Single("b4").Telegraph(2).Delay(1 + delay)
	Pattern.Single("c4").Telegraph(2).Delay(1 + delay)
	Pattern.Single("a1").Telegraph(2).Delay(2 + delay)
	Pattern.Single("a4").Telegraph(2).Delay(2 + delay)
	Pattern.Single("d1").Telegraph(2).Delay(2 + delay)
	Pattern.Single("d4").Telegraph(2).Delay(2 + delay)
	Pattern.Single("b1").Telegraph(2).Delay(3 + delay)
	Pattern.Single("c1").Telegraph(2).Delay(3 + delay)
	Pattern.Single("b4").Telegraph(2).Delay(3 + delay)
	Pattern.Single("c4").Telegraph(2).Delay(3 + delay)
	Pattern.Single("a1").Telegraph(2).Delay(4 + delay)
	Pattern.Single("a4").Telegraph(2).Delay(4 + delay)
	Pattern.Single("d1").Telegraph(2).Delay(4 + delay)
	Pattern.Single("d4").Telegraph(2).Delay(4 + delay)
	Pattern.Single("b1").Telegraph(2).Delay(5 + delay)
	Pattern.Single("c1").Telegraph(2).Delay(5 + delay)
	Pattern.Single("b4").Telegraph(2).Delay(5 + delay)
	Pattern.Single("c4").Telegraph(2).Delay(5 + delay)
	Pattern.Single("a1").Telegraph(2).Delay(6 + delay)
	Pattern.Single("a4").Telegraph(2).Delay(6 + delay)
	Pattern.Single("d1").Telegraph(2).Delay(6 + delay)
	Pattern.Single("d4").Telegraph(2).Delay(6 + delay)
	Pattern.Single("b1").Telegraph(2).Delay(7 + delay)
	Pattern.Single("c1").Telegraph(2).Delay(7 + delay)
	Pattern.Single("b4").Telegraph(2).Delay(7 + delay)
	Pattern.Single("c4").Telegraph(2).Delay(7 + delay)
	
func central_boombox_pattern_eight_beats(delay: int) -> void:
	Pattern.Single("a2").Telegraph(2).Delay(0 + delay)
	Pattern.Single("a3").Telegraph(2).Delay(0 + delay)
	Pattern.Single("d2").Telegraph(2).Delay(0 + delay)
	Pattern.Single("d3").Telegraph(2).Delay(0 + delay)
	Pattern.Single("b2").Telegraph(2).Delay(1 + delay)
	Pattern.Single("c2").Telegraph(2).Delay(1 + delay)
	Pattern.Single("b3").Telegraph(2).Delay(1 + delay)
	Pattern.Single("c3").Telegraph(2).Delay(1 + delay)
	Pattern.Single("a2").Telegraph(2).Delay(2 + delay)
	Pattern.Single("a3").Telegraph(2).Delay(2 + delay)
	Pattern.Single("d2").Telegraph(2).Delay(2 + delay)
	Pattern.Single("d3").Telegraph(2).Delay(2 + delay)
	Pattern.Single("b2").Telegraph(2).Delay(3 + delay)
	Pattern.Single("c2").Telegraph(2).Delay(3 + delay)
	Pattern.Single("b3").Telegraph(2).Delay(3 + delay)
	Pattern.Single("c3").Telegraph(2).Delay(3 + delay)
	Pattern.Single("a2").Telegraph(2).Delay(4 + delay)
	Pattern.Single("a3").Telegraph(2).Delay(4 + delay)
	Pattern.Single("d2").Telegraph(2).Delay(4 + delay)
	Pattern.Single("d3").Telegraph(2).Delay(4 + delay)
	Pattern.Single("b2").Telegraph(2).Delay(5 + delay)
	Pattern.Single("c2").Telegraph(2).Delay(5 + delay)
	Pattern.Single("b3").Telegraph(2).Delay(5 + delay)
	Pattern.Single("c3").Telegraph(2).Delay(5 + delay)
	Pattern.Single("a2").Telegraph(2).Delay(6 + delay)
	Pattern.Single("a3").Telegraph(2).Delay(6 + delay)
	Pattern.Single("d2").Telegraph(2).Delay(6 + delay)
	Pattern.Single("d3").Telegraph(2).Delay(6 + delay)
	Pattern.Single("b2").Telegraph(2).Delay(7 + delay)
	Pattern.Single("c2").Telegraph(2).Delay(7 + delay)
	Pattern.Single("b3").Telegraph(2).Delay(7 + delay)
	Pattern.Single("c3").Telegraph(2).Delay(7 + delay)
