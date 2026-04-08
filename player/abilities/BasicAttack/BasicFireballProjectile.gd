class_name BasicFireballProjectile extends Node3D

var startingPosition: Vector3

var Damage: float = 1.0
var MaximumTargets: int = 1
var MaximumBounce: int = 0
var BurnIntensity: float = 0.0

var targetsHit: Array[Dancer]

func _ready() -> void:
	$Area3D.area_entered.connect(OnCollision)
	await get_tree().process_frame
	startingPosition = global_position
	await get_tree().create_timer(2.5).timeout
	queue_free()

func OnCollision(other: Area3D) -> void:
	if isDestroyed or other.get_parent() is not Dancer:
		return

	var dancer: Dancer = other.get_parent()
	if dancer is Player or not dancer.isAlive or targetsHit.has(dancer):
		return

	targetsHit.append(dancer)
	dancer.DealDamage(BasicFireball.GetDamage())

	if BurnIntensity > 0.0 and dancer.isAlive:
		applyBurn(dancer)

	if MaximumBounce > 0:
		createBounceProjectile(dancer)

	if targetsHit.size() >= MaximumTargets:
		destroy()

func applyBurn(target: Dancer) -> void:
	Buff.Apply(BuffIgnite, target)

func createBounceProjectile(latestTarget: Dancer) -> void:
	var bouncedProjectile: BasicFireballProjectile = Asset.Instantiate(BasicFireballProjectile)
	bouncedProjectile.Damage = Damage
	bouncedProjectile.MaximumTargets = MaximumTargets
	bouncedProjectile.MaximumBounce = MaximumBounce - 1
	bouncedProjectile.BurnIntensity = BurnIntensity
	bouncedProjectile.targetsHit.append(latestTarget)
	get_parent().add_child(bouncedProjectile)
	bouncedProjectile.global_position = global_position

	var closestDancer: Dancer = null
	var distanceToCurrentClosest := INF
	for dancer: Dancer in GlobalContext.GetDanceFloor().GetAllDancers():
		if dancer is Player or dancer == latestTarget or not dancer.isAlive:
			continue

		var distanceToCurrent := dancer.global_position.distance_squared_to(global_position)
		if distanceToCurrent <= BasicFireball.MaxRange and (not closestDancer or distanceToCurrentClosest > distanceToCurrent):
			closestDancer = dancer
			distanceToCurrentClosest = distanceToCurrent

	if not closestDancer:
		bouncedProjectile.queue_free()
		return
	else:
		bouncedProjectile.look_at(closestDancer.global_position)

func destroy() -> void:
	isDestroyed = true
	$GPUParticles3D.emitting = false
	create_tween().tween_property($OmniLight3D, ^"omni_range", 0.0, 0.5)
	create_tween().tween_property($MeshInstance3D, ^"scale", Vector3.ZERO, 0.2)
	await get_tree().create_timer(0.5).timeout
	queue_free()

var isDestroyed := false

func _process(delta: float) -> void:
	if isDestroyed:
		return

	if global_position.distance_squared_to(startingPosition) > BasicFireball.MaxRange ** 2:
		destroy()
		return

	var forward := -global_transform.basis.z
	global_position += forward * 12.0 * delta
