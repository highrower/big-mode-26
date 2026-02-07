extends Behaviour

var target : Vector3

func execute(caller,_delta: float):
	$Node3D.look_at(target)
	for i in caller.get_children():
		if i.is_in_group("rotating"):
			i.rotation.y=$Node3D.rotation.y
