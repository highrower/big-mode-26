extends CharacterBody3D

@export var speed := 5.0
@export var target : Vector3
@export var damage := 5.0
func _physics_process(delta: float) -> void:
	var projectile_velocity = target.normalized()*speed*delta
	var collision = move_and_collide(projectile_velocity)
	if collision:
		var body = collision.get_collider()
		hit(body)

func hit(body):
	if body.is_in_group("damagable"):
		body.take_damage(damage)
