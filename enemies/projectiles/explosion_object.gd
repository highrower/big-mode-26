extends Area3D

@export var explosion_radius := 10.0
@export var explosion_power := 100.0
@export var explosion_damage := 20.0
@export var damage_to_groups : Array
var once = true
var particles: Array[GPUParticles3D]

func setup(explosion_power:float,explosion_damage:float,explosion_radius:float,damage_to_groups:Array):
	self.explosion_power=explosion_power
	self.explosion_damage=explosion_damage
	self.explosion_radius=explosion_radius
	self.damage_to_groups=damage_to_groups
	
func _ready() -> void:
	$CollisionShape3D.shape.radius = explosion_radius
	for child in get_children():
		if child is GPUParticles3D:
				particles.append(child)
				child.emitting=true

func _physics_process(delta: float) -> void:
	for i in get_overlapping_bodies():
		if once:
			if i is RigidBody3D:
				var explosion_vector = (i.global_position - self.global_position).normalized()
				i.apply_central_impulse(explosion_vector * explosion_power * i.mass)
			if i.is_in_group("damagable"):
				for group in damage_to_groups:
					if i.is_in_group(group):
						i.take_damage(explosion_damage)
						break
		once = false
	if not is_emitting():
		self.queue_free()

func is_emitting() -> bool:
	for p in particles:
		if p.emitting:
			return true
	return false
