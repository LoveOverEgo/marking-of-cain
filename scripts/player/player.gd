extends CharacterBody2D

@onready var player: CharacterBody2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var standing_collision_shape: CollisionShape2D = $StandingCollisionShape
@onready var sliding_collision_shape: CollisionShape2D = $SlidingCollisionShape

var crouch_ctrl := CrouchController.new()
var reset_default_after_animations = PackedStringArray(["stop_crouching", "stop_sliding"])

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if crouch_ctrl.is_sliding:
		crouch_ctrl.update_slide(player, delta)
	else:
		handle_jump()
		handle_direction(delta)
		crouch_ctrl.handle_crouch(player)
		
	move_and_slide()
	update_facing_direction()
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "start_sliding":
		set_animation("sliding")
		return
		
	if animated_sprite_2d.animation == "stop_sliding":
		crouch_ctrl.end_slide(standing_collision_shape, sliding_collision_shape)
	
	if reset_default_after_animations.has(animated_sprite_2d.animation):
		set_animation("default")
		return
		


## Applies gravity to velocity if not on the floor
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		

## Sets velocity of Y axis to JUMP_VELOCITY (negative value) if jump was pressed while on floor.
func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = get_meta("JUMP_VELOCITY")
		

## Updates horizontal velocity based on player input.
func handle_direction(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * get_meta("SPEED"),
			get_meta("ACCELERATION") * delta
		)		
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			get_meta("DECELERATION") * delta
		)
		

func get_animation_duration(animation_name: StringName) -> float:
	var sprite_frames := animated_sprite_2d.sprite_frames

	var frame_count := sprite_frames.get_frame_count(animation_name)
	var fps := sprite_frames.get_animation_speed(animation_name)

	return frame_count / fps
	

func set_animation(name: StringName) -> void:
	animated_sprite_2d.play(name)
	

## Updates the sprite's facing direction based on horizontal velocity.
func update_facing_direction() -> void:
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
		
