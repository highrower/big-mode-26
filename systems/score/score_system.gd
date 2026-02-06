extends Node

signal score_changed(score: int, multiplier: float)
signal heat_changed(stars: int, heat_progress: float)
signal rank_changed(rank_tier: int, rank_name: String, rank_progress: float)

@export_group("Score / Multiplier")
@export var base_multiplier: float = 1.0
@export var max_multiplier: float = 5.0

@export_group("Rank Meter")
@export var rank_points_per_base_score: float = 0.25
@export var rank_decay_per_second: float = 8.0
@export var rank_decay_delay: float = 1.25
@export var rank_thresholds: PackedFloat32Array = PackedFloat32Array([0, 30, 70, 120, 180, 260])
@export var rank_names: PackedStringArray = PackedStringArray(["D", "C", "B", "A", "S", "SS"])
@export var rank_multipliers: PackedFloat32Array = PackedFloat32Array([1.0, 1.2, 1.5, 2.0, 2.8, 3.5])

@export_group("Heat / Stars")
@export var max_stars: int = 5
@export var heat_per_kill: float = 18.0
@export var heat_per_destruction: float = 12.0
@export var heat_per_bat_hit: float = 6.0
@export var heat_decay_per_second: float = 4.0
@export var heat_decay_delay: float = 2.0
@export var heat_per_star: float = 100.0

@export_group("Penalties")
@export var multiplier_loss_on_player_hit: float = 0.5
@export var rank_points_loss_on_player_hit: float = 20.0

var score: int = 0
var multiplier: float = 1.0

var rank_points: float = 0.0
var rank_tier: int = 0

var heat: float = 0.0
var stars: int = 0

var _rank_time_since_gain: float = 999.0
var _heat_time_since_gain: float = 999.0


func reset_run() -> void:
	score = 0
	multiplier = base_multiplier

	rank_points = 0.0
	rank_tier = 0

	heat = 0.0
	stars = 0

	_rank_time_since_gain = 999.0
	_heat_time_since_gain = 999.0

	_recompute_rank_and_multiplier()
	_recompute_stars()
	_emit_all()


func add_score(amount: int, reason: String = "") -> void:
	if amount <= 0:
		return

	var gained := int(round(float(amount) * multiplier))
	score += gained

	_add_rank_points(float(gained) * rank_points_per_base_score)
	_emit_score()

func add_heat(amount: float, source: String = "") -> void:
	if amount == 0.0:
		return
		
	heat = max(0.0, heat + amount)
	_heat_time_since_gain = 0.0
	_recompute_stars()
	_emit_heat()

func on_enemy_defeated(base_points: int = 100) -> void:
	add_score(base_points, "enemy_defeated")
	add_heat(heat_per_kill, "enemy_defeated")

func on_terrain_destroyed(base_points: int = 50) -> void:
	add_score(base_points, "destroyed_terrain")
	add_heat(heat_per_destruction, "destroyed_terrain")
	
# Optional if we just want it to be one hit per enemy
func on_player_hit_enemy(rank_bonus: float = 0.0) -> void:
	if rank_bonus != 0.0:
		_add_rank_points(rank_bonus)
	add_heat(heat_per_bat_hit, "player_hit_enemy")

func on_player_got_hit() -> void:
	rank_points = max(0.0, rank_points - rank_points_loss_on_player_hit)
	_rank_time_since_gain = 0.0

	multiplier = max(base_multiplier, multiplier - multiplier_loss_on_player_hit)

	_recompute_rank_and_multiplier()
	_emit_rank()
	_emit_score()


func _ready() -> void:
	reset_run()


func _process(delta: float) -> void:
	_rank_decay(delta)
	_heat_decay(delta)


func _rank_decay(delta: float) -> void:
	_rank_time_since_gain += delta
	if _rank_time_since_gain >= rank_decay_delay and rank_points > 0.0:
		var before := rank_points
		rank_points = max(0.0, rank_points - rank_decay_per_second * delta)
		if rank_points != before:
			_recompute_rank_and_multiplier()
			_emit_rank()
			_emit_score()


func _heat_decay(delta: float) -> void:
	_heat_time_since_gain += delta
	if _heat_time_since_gain >= heat_decay_delay and heat > 0.0:
		var before_h := heat
		heat = max(0.0, heat - heat_decay_per_second * delta)
		if heat != before_h:
			_recompute_stars()
			_emit_heat()


func _add_rank_points(amount: float) -> void:
	if amount <= 0.0:
		return
	rank_points += amount
	_rank_time_since_gain = 0.0
	_recompute_rank_and_multiplier()
	_emit_rank()


func _recompute_rank_and_multiplier() -> void:
	var new_tier := _tier_from_thresholds(rank_points, rank_thresholds)
	new_tier = clamp(new_tier, 0, max(0, rank_names.size() - 1))

	if new_tier != rank_tier:
		rank_tier = new_tier
		emit_signal("rank_changed", rank_tier, _rank_name(rank_tier), get_rank_progress())

	multiplier = clamp(_multiplier_for_tier(rank_tier), base_multiplier, max_multiplier)


func _recompute_stars() -> void:
	var new_stars := int(floor(heat / heat_per_star))
	new_stars = clamp(new_stars, 0, max_stars)
	stars = new_stars

func _tier_from_thresholds(value: float, thresholds: PackedFloat32Array) -> int:
	var tier := 0
	for i in range(thresholds.size()):
		if value >= thresholds[i]:
			tier = i
		else:
			break
	return tier


func _rank_name(tier: int) -> String:
	if rank_names.size() == 0:
		return str(tier)
	return rank_names[clamp(tier, 0, rank_names.size() - 1)]


func _multiplier_for_tier(tier: int) -> float:
	if rank_multipliers.size() == 0:
		return base_multiplier
	return rank_multipliers[clamp(tier, 0, rank_multipliers.size() - 1)]


func get_rank_progress() -> float:
	if rank_thresholds.size() < 2:
		return 0.0
		
	var cur_i: int = clamp(rank_tier, 0, rank_thresholds.size() - 1)
	var next_i: int = clamp(cur_i + 1, 0, rank_thresholds.size() - 1)

	var cur := rank_thresholds[cur_i]
	var nxt := rank_thresholds[next_i]
	if nxt <= cur:
		return 1.0

	return clamp((rank_points - cur) / (nxt - cur), 0.0, 1.0)


func get_heat_progress() -> float:
	var within := fmod(heat, heat_per_star)
	return clamp(within / heat_per_star, 0.0, 1.0)


func _emit_score() -> void:
	emit_signal("score_changed", score, multiplier)


func _emit_heat() -> void:
	emit_signal("heat_changed", stars, get_heat_progress())


func _emit_rank() -> void:
	emit_signal("rank_changed", rank_tier, _rank_name(rank_tier), get_rank_progress())


func _emit_all() -> void:
	_emit_score()
	_emit_heat()
	_emit_rank()
