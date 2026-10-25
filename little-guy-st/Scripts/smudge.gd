extends CharacterBody2D
var player:Node2D

enum State {
	CHASE_Y,
	CHASE_X,
	ATTACK,
	COOLDOWN
}
var current_state: State = State.CHASE_Y

const SPEED = 150.0
const Y_TOLERANCE = 20.0
const ATTACK_RANGE = 45.0
const ATTACK_COOLDOWN = 1.0




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
			if abs(y_difference) > Y_TOLERANCE:
			# Move vertically toward player
				velocity.x = 0
				velocity.y = sign(y_difference) * SPEED
				print("Setting velocity",velocity)
				move_and_slide()
				
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
			if abs(y_difference) > Y_TOLERANCE:
				current_state = State.CHASE_Y
				velocity = Vector2.ZERO
			elif abs(x_difference) > ATTACK_RANGE:
				velocity.x = sign(x_difference) * SPEED
				velocity.y = 0
			else:
				velocity = Vector2.ZERO
				current_state = State.ATTACK
			move_and_slide()
		State.ATTACK:
			pass
		State.COOLDOWN:
			pass
