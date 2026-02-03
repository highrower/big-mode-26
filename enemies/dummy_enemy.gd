extends RigidBody3D
class_name EnemyObject

@export var health := 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_behaviour_manager(delta)

func _behaviour_manager(delta: float):
	for child in get_children():
		if child is Behaviour and child.enabled:
			child.execute(self,delta)

func take_damage(damage):
	self.health-=damage
	#print("Dummy Health:"+str(health))
