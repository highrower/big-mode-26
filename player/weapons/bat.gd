extends Area3D

@onready var Cooldown := $Cooldown
@export var CooldownTime := 2.0
@export var damage := 1
@export var knockback := 10
var can_attack := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Cooldown.wait_time=CooldownTime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false
		Cooldown.start()
		if has_overlapping_bodies():
			for i in get_overlapping_bodies():
				if i.is_in_group("damagable"):
					hit(i)

func hit(target):
	print("HIT")
	target.take_damage(damage)
	if target is RigidBody3D:
		var knockback_vector=(target.global_position-self.global_position).normalized()*knockback
		target.apply_central_impulse(knockback_vector)

func _on_cooldown_timeout() -> void:
	can_attack = true
