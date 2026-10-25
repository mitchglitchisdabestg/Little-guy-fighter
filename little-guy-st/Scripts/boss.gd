extends CharacterBody2D

var player: Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum State {
	CHASE_Y,
	CHASE_X,
	ATTACK,
	COOLDOWN
}
var current_state: State = State.CHASE_Y

const SPEED = 100.0
const Y_MIN_TOLERANCE = 10.0
const Y_MAX_TOLERANCE = 120.0
const ATTACK_RANGE = 45.0
const ATTACK_COOLDOWN = 1.0
const DEATH_SOUND = preload("res://Assets/Sound/Sound Effects/Ack.mp3")

var cooldown_timer: float = 0.0
var health: int = 30
var is_dead: bool = false # Guard flag to stop state machine on death

func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	health -= amount
	print("Stilts took damage : health: ", health)
	
	if health <= 0:
		is_dead = true
		velocity = Vector2.ZERO
		print("Stilts died")
		
		# Disable collision shape safely so bullets/player pass through during death
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
			
		play_death_sound()
		
		if animated_sprite_2d:
			animated_sprite_2d.play("Death")
			await animated_sprite_2d.animation_finished
			
		queue_free()

func play_death_sound() -> void:
	var sfx := AudioStreamPlayer.new()
	sfx.stream = DEATH_SOUND
	get_tree().current_scene.add_child(sfx)
	sfx.finished.connect(sfx.queue_free)
	sfx.play()

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	print("player found: ", player)

func _physics_process(delta: float) -> void:
	# Stop doing anything if dead
	if is_dead:
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if player and animated_sprite_2d:
		if player.global_position.x < global_position.x:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
			
	var x_difference = player.global_position.x - global_position.x if player else 0.0
	var y_difference = player.global_position.y - global_position.y if player else 0.0

	if player == null:
		return

	match current_state:
		State.CHASE_Y:
			var hit_boundary = false
			if get_slide_collision_count() > 0:
				var collider = get_slide_collision(0).get_collider()
				if collider and "boundray" in collider.name.to_lower():
					hit_boundary = true
					
			if abs(y_difference) > Y_MIN_TOLERANCE and not hit_boundary:
				velocity.x = 0
				velocity.y = sign(y_difference) * SPEED
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
			
		State.ATTACK:
			velocity = Vector2.ZERO
			if player and player.has_method("take_damage"):
				player.take_damage(10)
				if animated_sprite_2d:
					animated_sprite_2d.play("Attack")
			cooldown_timer = ATTACK_COOLDOWN
			current_state = State.COOLDOWN
			
		State.COOLDOWN:
			velocity = Vector2.ZERO
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				current_state = State.CHASE_Y
				
	move_and_slide()

func _on_damage_area_body_entered(body: Node2D) -> void:
	if not is_dead and body == player and body.has_method("take_damage"):
		body.take_damage(10)
