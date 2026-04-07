class_name BasicFireball extends Ability

var targetDirection := Vector3.RIGHT

static var BaseDamage := 1.0
static var MaxRange := 4 # tiles

static func GetDamage() -> float:
	var perkManager := GlobalContext.GetPlayer().perkManager
	var damage := BaseDamage
	if perkManager.Has(PerkRapidFireFireball):
		damage *= PerkRapidFireFireball.DamageMultiplier
	return damage

static func GetBurnDamage() -> float:
	var perkManager := GlobalContext.GetPlayer().perkManager
	return PerkIgnitingFireball.BaseDamage if perkManager.Has(PerkIgnitingFireball) else 0.0

static func GetPierce() -> int:
	var perkManager := GlobalContext.GetPlayer().perkManager
	var value := 0
	if perkManager.Has(PerkPiercingFireball):
		value = 100
	return value

static func GetBounce() -> int:
	var perkManager := GlobalContext.GetPlayer().perkManager
	var value := perkManager.Count(PerkBouncingFireball)
	return value

func _ready() -> void:
	SignalBus.OnFullBeat.connect(createProjectile)
	SignalBus.OnHalfBeat.connect(createProjectileIfHasRapidFire)

func createProjectileIfHasRapidFire(beat: float) -> void:
	if GlobalContext.GetPlayer().perkManager.Has(PerkRapidFireFireball):
		createProjectile(beat)

func createProjectile(_beat: float) -> void:
	var projectile := Asset.Instantiate(BasicFireballProjectile) as BasicFireballProjectile
	get_tree().root.add_child(projectile)
	projectile.Damage = GetDamage()
	projectile.BurnIntensity = GetBurnDamage()
	projectile.MaximumBounce = GetBounce()
	projectile.MaximumTargets = GetPierce() + 1
	projectile.global_position = GlobalContext.GetPlayer().global_position + Vector3(0.3, -0.08, -0.05)
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
