extends EnemyObject
@export var chase_speed = 50.0
@export var patrol_speed = 20.0
@onready var PlayerSight = $PlayerSight
@onready var ChasePlayer = $ChasePlayer
@onready var PatrolAround = $PatrolAround
@onready var ShootAt = $ShootAt
@onready var TurnRotating = $TurnRotating

func _physics_process(delta: float) -> void:
	if PlayerSight.target_visible:
		ChasePlayer.update_desired_range(20.0)
		ChasePlayer.speed = chase_speed
		var target = PlayerSight.last_raycast.get_collision_point()
		ChasePlayer.update_target(target)
		TurnRotating.target = target
		ShootAt.aim_at(target+Vector3.UP*2.0)
		ShootAt.shoot()
	else:
		ChasePlayer.update_desired_range(1.0)
		ChasePlayer.speed = patrol_speed
		var target = PatrolAround.target
		TurnRotating.target = target
		ChasePlayer.update_target(target)
	_behaviour_manager(delta)

func take_damage(damage):
	self.health-=damage
