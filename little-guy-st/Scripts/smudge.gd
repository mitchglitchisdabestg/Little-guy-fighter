extends CharacterBody2D
var player:Node2D
@onready var animated_sprite = $AnimatedSprite2D

enum State {
	CHASE_Y,
	CHASE_X,
	ATTACK,
	COOLDOWN
}
var current_state: State = State.CHASE_Y

const SPEED = 150.0
const Y_MIN_TOLERANCE = 10.0
const Y_MAX_TOLERANCE = 120.0
const ATTACK_RANGE = 45.0
const ATTACK_COOLDOWN = 1.0

var cooldown_timer: float = 0.0


var health: int = 30
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took damage : health: ", health)
	if health <= 0:
		print("Enemy died")
		animated_sprite.play("Death")
		await animated_sprite.animation_finished
		queue_free()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	print("player found",player)


func _physics_process(delta: float) -> void:
	if player == null:
		return
	var x_difference = player.global_position.x - global_position.x
	var y_difference = player.global_position.y - global_position.y
	print("State",current_state)
	print("X difference",x_difference)
	print("Y difference",y_difference)
	match current_state:
		State.CHASE_Y:
			var hit_boundary = false
			if get_slide_collision_count() > 0:
				var collider = get_slide_collision(0).get_collider()
				if collider and "boundray" in collider.name.to_lower():
					hit_boundary = true
					
			if abs(y_difference) > Y_MIN_TOLERANCE and not hit_boundary:
			# Move vertically toward player
				velocity.x = 0
				velocity.y = sign(y_difference) * SPEED
				print("Setting velocity",velocity)
				
				
				print("Slide collisions: ", get_slide_collision_count())

				if get_slide_collision_count() > 0:
					print("Hit: ", get_slide_collision(0).get_collider())
				
				print("after movement",global_position)
				print("velocity after movement",velocity)
				print("Colliding",is_on_wall(),"/",is_on_floor())
			else:
				velocity = Vector2.ZERO
				current_state = State.CHASE_X
	
		State.CHASE_X:
			if abs(y_difference) > Y_MAX_TOLERANCE:
				current_state = State.CHASE_Y
				velocity = Vector2.ZERO
			elif abs(x_difference) > ATTACK_RANGE:
				velocity.x = sign(x_difference) * SPEED
				velocity.y = 0
			else:
				velocity = Vector2.ZERO
				current_state = State.ATTACK
				#current_state = State.COOLDOWN
			
		State.ATTACK:
			velocity = Vector2.ZERO
			if player and player.has_method("take_damage"):
				player.take_damage(10)
			cooldown_timer = ATTACK_COOLDOWN
			current_state = State.COOLDOWN
		State.COOLDOWN:
			velocity = Vector2.ZERO
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				current_state = State.CHASE_Y
	move_and_slide()


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body == player and body.has_method("take_damage"):
		body.take_damage(10)
		
