extends CharacterBody2D

@onready var visuals = $Visuals
@onready var animated_sprite = $Visuals/AnimatedSprite2D
var sprite_start_y: float

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var is_acting: bool = false

const DEPTH_SPEED = 120.0
var depth_position: float
var jump_height: float = 0.0
var jump_velocity: float = 0.0

const Level_Top = 300.0
const Level_Bottom = 600.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if Input.is_action_just_pressed("Jump") and not is_acting:
		jump_velocity = JUMP_VELOCITY
		is_acting = true
		animated_sprite.play("Jump")
	# Handle jump.
	if is_acting:
		jump_velocity += 980.0 * delta
		jump_height += jump_velocity *delta
		
		if jump_height >= 0.0:
			jump_height = 0.0
			jump_velocity = 0.0
			is_acting = false

	visuals.position.y = sprite_start_y + jump_height


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector(
		"Left", "Right","Up", "Down"
		)
	
	if direction.x > 0 :
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
		
		
	if direction.x != 0:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x,0, SPEED)
		
	
	velocity.y = direction.y * DEPTH_SPEED
	move_and_slide()
	
	#position.y = clamp(position.y,Level_Top,Level_Bottom)
	depth_position = position.y


#Play animations
	if is_acting:
		if jump_velocity < 0:
			if animated_sprite.animation != "Jump":
				animated_sprite.play("Jump")
		else:
			if animated_sprite.animation != "Fall":
				animated_sprite.play("Fall")
	else:
		if direction == Vector2.ZERO:
			if animated_sprite.animation != "Idle":
				animated_sprite.play("Idle")
		else:
			if animated_sprite.animation != "Walk":
				animated_sprite.play("Walk")
		

		
func _ready() -> void:
	depth_position = clamp(position.y,Level_Top,Level_Bottom)
	position.y = depth_position
	sprite_start_y = visuals.position.y
