extends EnemyObject

@export var move_speed = 50.0
@export var fly_speed = 20.0
@export var fly_height = 50.0
@export var swoop_radius = 100.0
@export var explosion_distance = 30.0

@onready var Flying = $Flying
@onready var PlayerSight = $PlayerSight
@onready var MoveToward = $MoveToward
@onready var PatrolAround = $PatrolAround
@onready var DLCE = $DieLeaveCorpseExploed

func _physics_process(delta: float) -> void:
	if DLCE.is_dead:
		_behaviour_manager(delta)
		return
	Flying.speed=fly_speed
	if PlayerSight.target_visible:
		MoveToward.speed = move_speed
		var target = PlayerSight.last_raycast.get_collision_point()
		Flying.height=_swoop(self.global_position.distance_to(target))
		MoveToward.update_target(Vector3(target.x,self.global_position.y,target.z))
		if self.global_position.distance_to(target)<explosion_distance:
			take_damage(health)
			
	else:
		MoveToward.speed = move_speed
		var target = PatrolAround.target
		MoveToward.update_target(Vector3(target.x,self.global_position.y,target.z))
		Flying.height=fly_height
	_behaviour_manager(delta)

func _swoop(distance) -> float:
	var return_height = fly_height
	if distance<swoop_radius:
		return_height *= distance/swoop_radius 
	return return_height

func take_damage(damage):
	self.health-=damage
