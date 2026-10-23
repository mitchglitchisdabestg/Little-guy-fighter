extends Control
@onready var background = $Background
var sway_speed : float = 0.05
var screen_center : Vector2
var start_position : Vector2

@onready var new_game_button: Button = $MarginContainer/VBoxContainer/NewGameButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton
@onready var settings_button: Button = $MarginContainer/VBoxContainer/SettingsButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_center = get_viewport_rect().size / 2.0
	start_position = background.position
	
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/World/world.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	var mouse_pos = get_viewport().get_mouse_position()
	var offset = (mouse_pos - screen_center) * sway_speed
	background.position = start_position - offset


func _on_new_game_button_mouse_entered() -> void:
	new_game_button.text = ">> New Game"

func _on_new_game_button_mouse_exited() -> void:
	new_game_button.text = "New Game"

func _on_settings_button_mouse_entered() -> void:
	settings_button.text = ">> Settings"

func _on_settings_button_mouse_exited() -> void:
	settings_button.text = "Settings"

func _on_quit_button_mouse_entered() -> void:
	quit_button.text = ">> Quit"

func _on_quit_button_mouse_exited() -> void:
	quit_button.text = "Quit"
