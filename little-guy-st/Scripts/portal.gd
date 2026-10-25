extends Node2D

@export var next_level = "res://Scenes/World/world2.tscn"

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file.call_deferred(next_level)
