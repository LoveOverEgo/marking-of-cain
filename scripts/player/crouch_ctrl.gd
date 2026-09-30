class_name CrouchController
extends RefCounted

const SLIDE_SPEED: float = 200.0
const SLIDE_DURATION: float = 1.0

var is_crouching: bool = false
var is_sliding: bool = false
var slide_timer: float = 0.0
var slide_direction: float = 1.0

func handle_crouch(player: CharacterBody2D) -> void:
	if should_end_crouch():
		end_crouch(player)
		return
		
	if can_crouch(player):
		if abs(player.velocity.x) > 10.0:
			start_slide(player)
		else:
			start_crouch(player)
		return
		

func can_crouch(
	player: CharacterBody2D
) -> bool:
	return (
		Input.is_action_pressed("crouch")
		and player.is_on_floor
		and not is_crouching
	)
	

func should_end_crouch() -> bool:
	return (
		Input.is_action_just_released("crouch")
		and is_crouching
	)
	

func should_end_slide() -> bool:
	return slide_timer <= 0.0
	

func start_crouch(player: CharacterBody2D) -> void:
	is_crouching = true
	player.animated_sprite_2d.play("start_crouching")
	

func start_slide(player: CharacterBody2D) -> void:
	is_crouching = true
	is_sliding = true
	slide_timer = SLIDE_DURATION
	
	if player.velocity.x != 0:
		slide_direction = sign(player.velocity.x)
		
	player.velocity.x = slide_direction * SLIDE_SPEED
	
	player.standing_collision_shape.disabled = true
	player.sliding_collision_shape.disabled = false
	
	player.animated_sprite_2d.play("start_sliding")
	

func update_slide(player: CharacterBody2D, delta: float) -> void:
	slide_timer -= delta
	
	var move_from = player.velocity.x
	var move_to = slide_direction * player.get_meta("SPEED")
	var move_delta = player.get_meta("DECELERATION") * delta
	
	player.velocity.x = move_toward(move_from, move_to, move_delta)
	
	var end_slide_duration = player.get_animation_duration("stop_sliding");
	
	if slide_timer <= end_slide_duration:
		if player.animated_sprite_2d.animation != "stop_sliding":
			player.animated_sprite_2d.play("stop_sliding")
	elif (
		Input.is_action_just_released("crouch")
	):
		slide_timer = end_slide_duration
		player.animated_sprite_2d.play("stop_sliding")
		
	

func end_crouch(player: CharacterBody2D) -> void:
	is_crouching = false
	if player.animated_sprite_2d.animation != "default":
		player.animated_sprite_2d.play("stop_crouching")
		

func end_slide(standing_collision_shape, sliding_collision_shape) -> void:
	is_sliding = false
	slide_timer = 0.0
	standing_collision_shape.disabled = false
	sliding_collision_shape.disabled = true
	
