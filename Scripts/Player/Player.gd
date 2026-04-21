extends CharacterBody2D
class_name Player

# ========================
# CONFIG
# ========================
@export var speed: float = 100.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

# Y-SORT
@export var y_sort_offset: int = 0

# ========================
# STATE
# ========================
var input_direction: Vector2 = Vector2.ZERO

# ========================
# MAIN LOOP
# ========================
func _physics_process(delta: float) -> void:
	_read_input()
	_update_movement(delta)
	move_and_slide()

	_update_z_index()

# ========================
# INPUT
# ========================
func _read_input() -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Ajuste para vista 3/4
	input_direction.y *= 0.8

# ========================
# MOVEMENT
# ========================
func _update_movement(delta: float) -> void:
	if input_direction != Vector2.ZERO:
		var target_velocity: Vector2 = input_direction.normalized() * speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

# ========================
# Y SORT
# ========================
func _update_z_index() -> void:
	z_index = int(global_position.y) + y_sort_offset

# ========================
# API
# ========================
func get_current_velocity() -> Vector2:
	return velocity

func get_max_speed() -> float:
	return speed

func is_moving() -> bool:
	return velocity.length() > 5.0
