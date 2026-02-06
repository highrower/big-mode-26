extends Behaviour

var can_attack : bool = true
@export var projectile_scene : PackedScene
@export var speed := 50.0
@export var damage := 50.0
@export var can_damage_groups : Array

func _on_cooldown_timeout() -> void:
	can_attack = true

func execute(caller,_delta: float):
	pass

func aim_at(target):
	$Node3D.look_at(target)

func shoot():
	if can_attack:
		var projectile = projectile_scene.instantiate()
		projectile.position = $Node3D.global_position
		projectile.transform.basis = $Node3D.global_transform.basis
		projectile.setup(speed,damage,can_damage_groups)
		get_tree().root.add_child(projectile)
		can_attack=false
		$Cooldown.start()
