extends EnemyObject

@onready var PlayerSight = $PlayerSight
@onready var ChasePlayer = $ChasePlayer

func _physics_process(delta: float) -> void:
	if PlayerSight.target_visible:
		var target = PlayerSight.last_raycast.get_collision_point()
		ChasePlayer.update_target(target)
	_behaviour_manager(delta)

func take_damage(damage):
	self.health-=damage
