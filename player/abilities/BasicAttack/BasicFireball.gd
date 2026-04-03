class_name BasicFireball extends Ability

var targetDirection := Vector3.RIGHT

func _ready() -> void:
	SignalBus.OnBasicBeat.connect(on_basic_beat)

func on_basic_beat() -> void:
	var projectile := Asset.Instantiate(BasicFireballProjectile) as BasicFireballProjectile
	get_tree().root.add_child(projectile)
	projectile.global_position = GlobalContext.GetPlayer().global_position + Vector3(0.35, -0.08, -0.05)
	projectile.look_at(projectile.global_position + targetDirection * 90.0)
	if isAutoAim:
		projectile.look_at(GlobalContext.GetBoss().global_position)

func SetTargetDirection(direction: Vector3) -> void:
	targetDirection = direction

var isAutoAim := false
func SetAutoAim(value: bool) -> void:
	isAutoAim = value

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mousePosition := controller.GetMouseWorldPlanePosition()
		var direction := mousePosition - Vector3(player.global_position.x, 0.0, player.global_position.z)
		var angle := Vector3.RIGHT.signed_angle_to(direction, Vector3.UP)
		if angle < PI / 4.0 and angle > -PI / 4.0:
			targetDirection = Vector3.RIGHT
		elif angle > 0 and angle < PI / 2.0 + PI / 4.0:
			targetDirection = Vector3.FORWARD
		elif angle < 0 and angle > -PI / 2.0 - PI / 4.0:
			targetDirection = Vector3.BACK
		else:
			targetDirection = Vector3.LEFT
