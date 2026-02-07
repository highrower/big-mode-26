extends Behaviour

@export var explosion_power := 2.5
@export var explosion_damage := 100.0
@export var explosion_radius := 15.0
@export var damage_to_groups : Array[String]

signal died
var is_dead : bool = false
var explosion_scene = preload("res://enemies/projectiles/explosion_object.tscn")

func execute(caller,delta: float):
	if caller.health<=0:
		die(caller,delta)
		self.enabled=false

func die(caller,_delta: float):
	died.emit()
	is_dead = true
	$GPUParticles3D.emitting=true
	$Timer.start()
	for i in caller.get_children():
		if i is Behaviour and i!=self:
			i.queue_free()


func _on_timer_timeout() -> void:
	var explosion = explosion_scene.instantiate()
	explosion.setup(explosion_power,explosion_damage,explosion_radius,damage_to_groups)
	get_tree().root.add_child(explosion)
	explosion.global_position = $Node3D.global_position
	owner.queue_free()
