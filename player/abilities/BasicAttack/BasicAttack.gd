class_name BasicAttack extends BaseAbility


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.OnBasicBeat.connect(on_basic_beat)

func on_basic_beat() -> void:
	var projectile := Asset.Instantiate(BasicAttackProjectile) as BasicAttackProjectile
	get_tree().root.add_child(projectile)
	projectile.global_position = GlobalContext.GetPlayer().global_position + Vector3(0.35, -0.08, -0.05)
	projectile.global_rotation_degrees = Vector3(0.0, -90.0, 0.0)
	if isAutoAim:
		projectile.look_at(GlobalContext.GetBoss().global_position)

var isAutoAim := false
func SetAutoAim(value: bool) -> void:
	isAutoAim = value
