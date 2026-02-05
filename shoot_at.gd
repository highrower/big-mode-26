extends Behaviour

@export var projectile_damage := 20.0
@export var projectile_speed := 50.0
var target : Vector3
var can_attack : bool = true
var attack_cooldown := 1.0
var windup_time := 1.0
@export var projectile_path : PackedScene
var can_damage_array := ["player_team"]

func _ready() -> void:
	$WindUp.wait_time=attack_cooldown
	$Cooldown.wait_time=windup_time
	
func execute(caller,_delta: float):
	pass

func shoot():
	if can_attack:
		$WindUp.start()
		can_attack = false

func _on_wind_up_timeout() -> void:
	var projectile = projectile_path.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position=$Node3D.global_position
	projectile.setup(projectile_speed,projectile_damage,can_damage_array)
	projectile.set_target(target)
	$Marker3D.global_position=target
	$Cooldown.start()

func _on_cooldown_timeout() -> void:
	can_attack = true

func aim_at(new_target : Vector3) -> void:
	target = new_target
	
