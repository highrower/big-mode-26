extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	# We can rename later
	get_tree().change_scene_to_file("res://levels/level_01.tscn")

func _on_quit_pressed():
	get_tree().quit()
