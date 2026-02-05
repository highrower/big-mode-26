extends Area3D

@export var explosion_radius := 10.0
@export var explosion_power := 100.0
@export var explosion_damage := 20.0
@export var damage_to_groups : Array
@onready var particles
# Called when the node enters the scene tree for the first time.

func setup(explosion_radius:float,explosion_power:float,explosion_damage:float,damage_to_groups:Array):
	self.explosion_radius=explosion_radius
	self.explosion_power=explosion_power
	self.explosion_damage=explosion_damage
	self.damage_to_groups=damage_to_groups
	
func _ready() -> void:
	for i in get_overlapping_bodies():
		if i is RigidBody3D:
			var explosion_vector = (i.global_position - self.global_position).normalized()
			i.apply_central_impulse(explosion_vector * explosion_power)
		
