extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 350.0
const JUMP_VELOCITY = -600.0
var is_acting: bool = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_acting = true
		animated_sprite.play("Jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction > 0 :
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()	
#Play animations
	if is_acting:	
		if animated_sprite.animation == "Jump" and not animated_sprite.is_playing():
			animated_sprite.play("Fall")
		if is_on_floor() and velocity.y >= 0:
			is_acting = false
	else:
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("Walk")
		
	
		
	
