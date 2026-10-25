extends Control

@onready var new_game_button: Button = $Buttons/NewGameButton
@onready var quit_button: Button = $Buttons/QuitButton
@onready var settings_button: Button = $Buttons/SettingsButton

func pop(button, big):
	button.pivot_offset = button.size / 2
	var s = 1.1 if big else 1.0
	create_tween().tween_property(button, "scale", Vector2(s, s), 0.1)

func _on_new_game_button_pressed() -> void:
	$sfx_jump_start.play()
	get_tree().change_scene_to_file("res://Scenes/World/world.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_new_game_button_mouse_entered() -> void:
	pop(new_game_button, true)

func _on_new_game_button_mouse_exited() -> void:
	pop(new_game_button, false)

func _on_settings_button_mouse_entered() -> void:
	pop(settings_button, true)

func _on_settings_button_mouse_exited() -> void:
	pop(settings_button, false)

func _on_quit_button_mouse_entered() -> void:
	pop(quit_button, true)

func _on_quit_button_mouse_exited() -> void:
	pop(quit_button, false)
