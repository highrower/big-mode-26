# audio_system.gd
extends Node

const CATALOG_PATH := "res://systems/audio/catalog/audio_catalog.tres"

class Sfx:
	const HIT := &"sfx_hit"
	const EXPLOSION := &"sfx_explosion"

class UI:
	const CLICK := &"ui_click"
	const HOVER := &"ui_hover"

class Music:
	const MAIN := &"music_main"

@export var sfx_players := 8
@export var ui_players := 4

var _sfx_pool: Array[AudioStreamPlayer] = []
var _ui_pool: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer

var _sfx_index := 0
var _ui_index := 0

var _sfx_map: Dictionary = {}
var _ui_map: Dictionary = {}
var _music_map: Dictionary = {}

var _warned_missing: Dictionary = {} # avoids output spam if audio is missing

func _ready() -> void:
	_sfx_pool = _make_pool(sfx_players, "SFX")
	_ui_pool = _make_pool(ui_players, "UI")

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_load_catalog()


func _load_catalog() -> void:
	_sfx_map.clear()
	_ui_map.clear()
	_music_map.clear()
	_warned_missing.clear()

	var catalog := load(CATALOG_PATH) as AudioCatalog
	if catalog == null:
		push_warning("[AudioSystem] Missing catalog at %s" % CATALOG_PATH)
		return

	_index_entries(catalog.sfx, _sfx_map, "SFX")
	_index_entries(catalog.ui, _ui_map, "UI")
	_index_entries(catalog.music, _music_map, "Music")

	print("[AudioSystem] Catalog loaded. sfx=%d ui=%d music=%d" % [
		_sfx_map.size(), _ui_map.size(), _music_map.size()
	])


func play_sfx(id: StringName, volume_db: float = INF, pitch_range: float = INF) -> void:
	var entry := _sfx_map.get(id) as SoundEntry
	if not _can_play(entry, id):
		return

	var p := _sfx_pool[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_pool.size()

	p.stop()
	p.stream = entry.stream
	p.volume_db = entry.default_volume_db if volume_db == INF else volume_db
	p.pitch_scale = _rand_pitch(entry.default_pitch_range if pitch_range == INF else pitch_range)
	p.play()


func play_ui(id: StringName, volume_db: float = INF, pitch_range: float = INF) -> void:
	var entry := _ui_map.get(id) as SoundEntry
	if not _can_play(entry, id):
		return

	var p := _ui_pool[_ui_index]
	_ui_index = (_ui_index + 1) % _ui_pool.size()

	p.stop()
	p.stream = entry.stream
	p.volume_db = entry.default_volume_db if volume_db == INF else volume_db
	p.pitch_scale = _rand_pitch(entry.default_pitch_range if pitch_range == INF else pitch_range)
	p.play()


func play_music(id: StringName, volume_db: float = INF, loop: bool = true) -> void:
	var entry := _music_map.get(id) as SoundEntry
	if not _can_play(entry, id):
		return

	_music_player.stop()
	_music_player.stream = entry.stream
	_music_player.volume_db = entry.default_volume_db if volume_db == INF else volume_db
	print("music_player.volume_db actually set to: ", _music_player.volume_db, " bus=", _music_player.bus)
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func _index_entries(entries: Array[SoundEntry], map: Dictionary, label: String) -> void:
	for e in entries:
		if e == null:
			continue
		if e.id == StringName():
			push_warning("[AudioSystem] %s entry missing id" % label)
			continue
		map[e.id] = e


func _can_play(entry: SoundEntry, id: StringName) -> bool:
	if entry == null:
		_warn_once(id, "[AudioSystem] Missing entry for id: %s" % String(id))
		return false

	if not entry.enabled:
		return false

	if entry.stream == null:
		_warn_once(id, "[AudioSystem] No stream assigned yet for id: %s" % String(id))
		return false

	return true


func _warn_once(key: StringName, msg: String) -> void:
	if _warned_missing.has(key):
		return
	_warned_missing[key] = true
	push_warning(msg)


func _make_pool(count: int, bus: String) -> Array[AudioStreamPlayer]:
	var pool: Array[AudioStreamPlayer] = []
	for i in count:
		var p := AudioStreamPlayer.new()
		p.bus = bus
		add_child(p)
		pool.append(p)
	return pool


func _rand_pitch(range_amount: float) -> float:
	if range_amount <= 0.0:
		return 1.0
	return randf_range(1.0 - range_amount, 1.0 + range_amount)
