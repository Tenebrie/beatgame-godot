class_name BasicAttack extends BaseAbility

var targetDirection := Vector3.RIGHT

func _ready() -> void:
	SignalBus.OnBasicBeat.connect(on_basic_beat)

func on_basic_beat() -> void:
	var projectile := Asset.Instantiate(BasicAttackProjectile) as BasicAttackProjectile
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
