extends Behaviour

@export var damage := 20.0
var can_attack : bool = true
var attack_cooldown := 1.0
var windup_time := 1.0

func _ready() -> void:
	$WindUp.wait_time=attack_cooldown
	$Cooldown.wait_time=windup_time
	
func execute(caller,_delta: float):
	pass

func _on_hurtbox_area_entered(area: Area3D) -> void:
	if can_attack:
		var tween = create_tween()
		tween.tween_property($TempAnim,"rotation:y",0.5*PI,1.0)
		$WindUp.start()
		can_attack = false

func _on_wind_up_timeout() -> void:
	var tween = create_tween()
	tween.tween_property($TempAnim,"rotation:y",-2.5*PI,1.0)
	for i in $Hurtbox.get_overlapping_bodies():
		if i.is_in_group("player_team") and i.is_in_group("damagable"):
			i.take_damage(damage)
			$Cooldown.start()

func _on_cooldown_timeout() -> void:
	can_attack = true
