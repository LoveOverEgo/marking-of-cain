extends Node2D

const SPEED = 60
var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var wall_right: bool = ray_cast_right.is_colliding()
	var wall_left: bool = ray_cast_left.is_colliding() 
	
	if wall_right:
		direction = -1
	if wall_left:
		direction = 1
		
	position.x += direction * SPEED * delta
