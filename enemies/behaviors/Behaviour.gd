@abstract
extends Node
class_name Behaviour

@export var enabled: bool = true

@abstract func execute(caller,_delta: float)
