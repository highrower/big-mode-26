extends Area3D

@onready var Cooldown := $Cooldown
@export var CooldownTime := 1.0
@export var damage := 50.0
@export var knockback := 25.0
var can_attack := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Cooldown.wait_time=CooldownTime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false
		#Placeholder Animation Tween for Macks!
		var tween = create_tween()
		tween.tween_property($TempAnim,"rotation:y",-PI,0.3)
		tween.tween_property($TempAnim,"rotation:y",0.0,0.1)
		#this is probably horrible please delete this later, I'm not killing the tween here since that doesn't make the animation play??
		Cooldown.start()
		if has_overlapping_bodies():
			for i in get_overlapping_bodies():
				if i.is_in_group("enemy_team") and i.is_in_group("damagable"):
					hit(i)
				if i.is_in_group("parryable"):
					i.parry()

func hit(target):
	target.take_damage(damage)
	if target is RigidBody3D:
		var knockback_vector=(target.global_position-get_parent().global_position).normalized()*knockback
		target.apply_central_impulse(knockback_vector)

func _on_cooldown_timeout() -> void:
	can_attack = true
