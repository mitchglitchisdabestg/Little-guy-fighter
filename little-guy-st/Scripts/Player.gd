extends CharacterBody2D

@onready var visuals = $Visuals
@onready var animated_sprite = $Visuals/AnimatedSprite2D
var sprite_start_y: float

@onready var jump_sfx: AudioStreamPlayer = $jump_sfx

#regularspeed and jump
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var is_acting: bool = false
var jump_height: float = 0.0
var jump_velocity: float = 0.0

#Dashing setup
const DASH_SPEED = 400.0
const DASH_DURATION = 0.2
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 0.0

#Attack setup
var is_shooting: bool = false
var is_charging: bool = false
var is_charge_beam: bool = false
const PROJECTILE_SCENE = preload("res://Scenes/Attack/Projectiles/projectile.tscn")
const BEAM_SCENE = preload("res://Scenes/Attack/Projectiles/beam.tscn")


#streets of rage movement (up and down the street)
const DEPTH_SPEED = 120.0
var depth_position: float

#level boundrarys (not used anymore)
const Level_Top = 300.0
const Level_Bottom = 600.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if Input.is_action_just_pressed("Jump") and not is_acting and not is_shooting and not is_charging and not is_charge_beam and not is_dashing:
		jump_velocity = JUMP_VELOCITY
		is_acting = true
		animated_sprite.play("Jump")
		jump_sfx.play()
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
		
	#Handle the attacking states
	if Input.is_action_just_pressed("Attack") and not is_shooting and not is_acting and not is_charging and not is_dashing:
		is_shooting = true
		animated_sprite.play("Pew_Pew")
		shoot_projectile()
	if Input.is_action_just_pressed("Charged") and not is_shooting and not is_acting and not is_charging and not is_dashing:
		is_charging = true
		animated_sprite.play("Kamekame")
	if Input.is_action_just_released("Charged") and is_charging:
		is_charging = false
		is_charge_beam = true
		animated_sprite.play("Ha")
		beam_shoot()
	
	#checking direction, and then flippng the sprite horizontially accordingly
	if direction.x > 0 :
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
		
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		if direction.x != 0:
			velocity.x = direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x,0, SPEED)
		
	
	velocity.y = direction.y * DEPTH_SPEED
	move_and_slide()
	
	#position.y = clamp(position.y,Level_Top,Level_Bottom)
	depth_position = position.y
	
	if Input.is_action_just_pressed("Dash") and not is_acting:
		if direction.x != 0:
			dash_direction = sign(direction.x)
		else: dash_direction = -1 if animated_sprite.flip_h else 1
		
		is_dashing = true
		dash_timer = DASH_DURATION
		animated_sprite.play("Dash")


#Play animations
	if is_shooting or is_charging or is_charge_beam:
		pass
	elif is_dashing: 
		if animated_sprite.animation != "Dash":
			animated_sprite.play("Dash")
	elif is_acting:
		if jump_velocity < 0:
			if animated_sprite.animation != "Jump":
				animated_sprite.play("Jump")
		else:
			if animated_sprite.animation != "Fall":
				animated_sprite.play("Fall")
		pass
	else:
		if direction == Vector2.ZERO:
			if animated_sprite.animation != "Idle":
				animated_sprite.play("Idle")
		else:
			if animated_sprite.animation != "Walk":
				animated_sprite.play("Walk")
		pass

		
func _ready() -> void:
	depth_position = clamp(position.y,Level_Top,Level_Bottom)
	position.y = depth_position
	sprite_start_y = visuals.position.y


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Pew_Pew":
		is_shooting = false

	elif animated_sprite.animation == "Ha":
		is_charge_beam = false


func shoot_projectile() -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.direction = -1.0 if animated_sprite.flip_h else 1.0
	var spawn_offset =Vector2(
		-5 if animated_sprite.flip_h else 5,
		-5
		)
	projectile.global_position = global_position + spawn_offset
	get_tree().current_scene.add_child(projectile)
	
func beam_shoot() -> void:
	var beam = BEAM_SCENE.instantiate()
	beam.direction = -1.0 if animated_sprite.flip_h else 1.0

	
	var spawn_offset =Vector2(
		-2 if animated_sprite.flip_h else 2,
		-2
		)
	beam.global_position = global_position + spawn_offset
	get_tree().current_scene.add_child(beam)
