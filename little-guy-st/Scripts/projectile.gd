extends Area2D

const SPEED = 450.0
var direction:float = 1.0

func _physics_process(delta: float) -> void:
		global_position.x += direction * SPEED *delta
		
signal hit_something

const DAMAGE = 1

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)

	queue_free()
