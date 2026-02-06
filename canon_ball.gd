extends CharacterBody3D

@export var speed := 50.0
@export var damage := 50.0
var can_damage_groups : Array

func setup(speed,damage,can_damage_groups):
	self.speed = speed
	self.damage = damage
	self.can_damage_groups = can_damage_groups


func _physics_process(delta: float) -> void:
	var next_velocity=transform.basis * Vector3.FORWARD *speed * delta
	var collision = move_and_collide(next_velocity)
	if collision:
		var body = collision.get_collider()
		hit(body)

func hit(body):
	if body.is_in_group("damagable"):
		for group in can_damage_groups:
			if body.is_in_group(group):
				body.take_damage(damage)
				break
	self.queue_free()
