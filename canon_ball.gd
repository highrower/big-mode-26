extends CharacterBody3D

@export var speed := 5.0
@export var target : Vector3
@export var damage := 50.0
var can_damage_groups : Array

func setup(speed,damage,can_damage_array):
	self.speed = speed
	self.damage = damage
	self.can_damage_groups = can_damage_array

func set_target(target):
	self.target=target

func _physics_process(delta: float) -> void:
	var projectile_velocity = (target-self.global_position).normalized()*speed*delta
	var collision = move_and_collide(projectile_velocity)
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
