extends Area2D

const SPEED = 450.0
var direction:float = 1.0

func _physics_process(delta: float) -> void:
		global_position.x += direction * SPEED *delta
		
signal hit_something

const DAMAGE = 10

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemys") and body.has_method("take_damage"):
		body.take_damage(10)
		queue_free()
