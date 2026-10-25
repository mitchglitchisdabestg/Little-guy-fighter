extends Node2D

@export var scene_name = "park"
var done = false

func _process(_delta):
	if done:
		return
	var player = get_tree().current_scene.get_node("Player")
	if player.global_position.x > global_position.x:
		done = true
		var talk = load("res://Scenes/UI/Dialouge/tutorial_dialouge.tscn").instantiate()
		talk.scene_name = scene_name
		get_tree().current_scene.add_child(talk)
