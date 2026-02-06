extends Node

const SFX_DIR := "res://audio/sfx"
const UI_DIR := "res://audio/ui"
const MUSIC_DIR := "res://audio/music"

@export var sfx_players := 8
@export var ui_players := 4

var sfx := {}
var ui := {}
var music := {}

var _sfx_pool: Array[AudioStreamPlayer] = []
var _ui_pool: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer

var _sfx_index := 0
var _ui_index := 0


func _ready() -> void:
	_sfx_pool = _make_pool(sfx_players, "SFX")
	_ui_pool = _make_pool(ui_players, "UI")

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	sfx = _load_library(SFX_DIR)
	ui = _load_library(UI_DIR)
	music = _load_library(MUSIC_DIR)

	print("[AudioSystem] Loaded: sfx=%d ui=%d music=%d" % [sfx.size(), ui.size(), music.size()])


func play_sfx(name: String, volume_db: float = 0.0, pitch_range: float = 0.0) -> void:
	var stream: AudioStream = sfx.get(name)
	if stream == null:
		push_warning("[AudioSystem] Missing SFX: %s" % name)
		return

	var p := _sfx_pool[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_pool.size()

	p.stop()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = _rand_pitch(pitch_range)
	p.play()


func play_ui(name: String, volume_db: float = 0.0, pitch_range: float = 0.0) -> void:
	var stream: AudioStream = ui.get(name)
	if stream == null:
		push_warning("[AudioSystem] Missing UI: %s" % name)
		return

	var p := _ui_pool[_ui_index]
	_ui_index = (_ui_index + 1) % _ui_pool.size()

	p.stop()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = _rand_pitch(pitch_range)
	p.play()


func play_music(name: String, volume_db: float = -6.0, loop: bool = true) -> void:
	var stream: AudioStream = music.get(name)
	if stream == null:
		push_warning("[AudioSystem] Missing Music: %s" % name)
		return

	_music_player.stop()
	_music_player.stream = stream
	_music_player.volume_db = volume_db

	# Many music formats loop via import settings. This is a best-effort toggle.
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	elif stream is AudioStreamWav:
		(stream as AudioStreamWav).loop_mode = AudioStreamWav.LOOP_FORWARD if loop else AudioStreamWav.LOOP_DISABLED

	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


# --- helpers ---

func _make_pool(count: int, bus: String) -> Array[AudioStreamPlayer]:
	var pool: Array[AudioStreamPlayer] = []
	for i in count:
		var p := AudioStreamPlayer.new()
		p.bus = bus
		add_child(p)
		pool.append(p)
	return pool


func _load_library(dir_path: String) -> Dictionary:
	var lib := {}

	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("[AudioSystem] Could not open dir: %s" % dir_path)
		return lib

	dir.list_dir_begin()
	while true:
		var file := dir.get_next()
		if file == "":
			break
		if dir.current_is_dir():
			continue

		var ext := file.get_extension().to_lower()
		if ext != "ogg" and ext != "wav" and ext != "mp3":
			continue

		var key := file.get_basename() # filename without extension
		var path := "%s/%s" % [dir_path, file]
		var stream := load(path)
		if stream != null:
			lib[key] = stream

	dir.list_dir_end()
	return lib


func _rand_pitch(range_amount: float) -> float:
	if range_amount <= 0.0:
		return 1.0
	return randf_range(1.0 - range_amount, 1.0 + range_amount)
