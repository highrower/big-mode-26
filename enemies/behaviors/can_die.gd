extends Behaviour

signal died

func execute(caller,delta: float):
	if caller.health<=0:
		die(caller,delta)

func die(caller,_delta: float):
	died.emit()
	caller.queue_free()
