extends Area2D

const SPEED = 450.0
var direction:float = 1.0

func _physics_process(delta: float) -> void:
	global_position.x += direction * SPEED *delta
