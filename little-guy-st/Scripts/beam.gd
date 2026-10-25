extends Area2D

const DAMAGE = 15
const EXIST = 1

var direction: float = 1.0
var hit_targets: Array[Node2D]=[]

func _ready() -> void:
	scale.x = direction
	$Start.play("default")
	$Mid.play("default")
	$End.play("default")

	await get_tree().create_timer(EXIST).timeout
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body in hit_targets:
		return

	if body.has_method("take_damage"):
		hit_targets.append(body)
		body.take_damage(DAMAGE)
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemys") and body.has_method("take_damage"):
		body.take_damage(DAMAGE)
		queue_free()
