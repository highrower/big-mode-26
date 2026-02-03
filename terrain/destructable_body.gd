extends RigidBody3D

@export var destronoi_node_path: NodePath = ^"DestronoiNode"

# These match the example you posted.
@export var left_depth: int = 5
@export var right_depth: int = 5
@export var blast_velocity: float = 10.0

# Optional: prevent repeated explosions if you hold space or spam it
@export var one_shot: bool = true
var _has_destroyed := false

func _ready() -> void:
	# Not required, but gives you an early error instead of silent nothing.
	if not has_node(destronoi_node_path):
		push_error("DestronoiNode not found at path: %s" % [destronoi_node_path])

func _unhandled_input(event: InputEvent) -> void:
	# If you don't want to add an input action, you can use raw spacebar:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_destroy_now()

func _destroy_now() -> void:
	if one_shot and _has_destroyed:
		return

	var destronoi_node := get_node_or_null(destronoi_node_path)
	if destronoi_node == null:
		push_error("DestronoiNode missing; cannot destroy.")
		return

	# Call the addon method. If the method name differs, you'll get a helpful error below.
	if destronoi_node.has_method("destroy"):
		destronoi_node.destroy(left_depth, right_depth, blast_velocity)
		_has_destroyed = true
	else:
		push_error("Node at %s has no method destroy(). Check the script is attached and the addon loaded."
			% [destronoi_node_path])
