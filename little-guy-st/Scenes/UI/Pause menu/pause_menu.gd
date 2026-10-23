extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_panel: PanelContainer = $MainPanel

var last_mouse_state := Input.MouseMode.MOUSE_MODE_CAPTURED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_panel.hide()
	animation_player.play("RESET")

func check_can_pause(): #-> bool:
	pass

func pause_tree() -> void:
	last_mouse_state = Input.mouse_mode
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	main_panel.visible = true
	animation_player.play("blur")

func resume_tree() -> void:
	Input.set_mouse_mode(last_mouse_state)
	get_tree().paused = false
	main_panel.visible = false
	animation_player.play_backwards("unblur")

func _unhandled_input(event: InputEvent) -> void:
	# If we ain't pausing, we don't care
	if !event.is_action_pressed("Pause"): return
	
	if get_tree().paused:
		resume_tree()
	else:
		pause_tree()

func _on_resume_pressed() -> void:
	resume_tree()

func _on_restart_pressed() -> void:
	resume_tree()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
