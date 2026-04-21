extends Node

# ========================
# REFERENCES
# ========================
@export var player: Player
@export var player_spawn: Marker2D
@export var spawn_container: Node2D
@export var car_scene: PackedScene

# ========================
# CONFIG
# ========================
@export var base_time: float = 5.0
@export var time_decrease_per_round: float = 0.05
@export var min_time: float = 2.5

@export var initial_car_count: int = 2

# ========================
# STATE
# ========================
var current_cars: Array[UsableLocation] = []
var spawn_points: Array[Marker2D] = []

var score: int = 0
var current_car_count: int = 0

var time_left: float = 0.0
var is_round_active: bool = false

# ========================
# INIT
# ========================
func _ready() -> void:
	_collect_spawn_points()
	start_game()

# ========================
# LOOP
# ========================
func _process(delta: float) -> void:
	if not is_round_active:
		return

	time_left -= delta

	if time_left <= 0:
		_on_time_out()

# ========================
# GAME FLOW
# ========================
func start_game() -> void:
	score = 0
	current_car_count = initial_car_count
	_start_round()

func next_round() -> void:
	score += 1
	current_car_count += 1
	_start_round()

func _start_round() -> void:
	is_round_active = true
	
	_reset_player()
	_clear_cars()
	_spawn_cars()
	_reset_timer()

# ========================
# PLAYER
# ========================
func _reset_player() -> void:
	player.global_position = player_spawn.global_position
	player.velocity = Vector2.ZERO

# ========================
# SPAWN SYSTEM
# ========================
func _collect_spawn_points() -> void:
	for child in spawn_container.get_children():
		if child is Marker2D:
			spawn_points.append(child)

func _spawn_cars() -> void:
	var available_points = spawn_points.duplicate()
	available_points.shuffle()

	var car_count: int = clamp(current_car_count, 1, spawn_points.size())
	var selected_points = available_points.slice(0, car_count)

	var valid_index: int = randi() % selected_points.size()

	for i in selected_points.size():
		var car: UsableLocation = car_scene.instantiate()
		
		var is_valid: bool = (i == valid_index)
		car.setup(is_valid)

		car.global_position = selected_points[i].global_position
		
		add_child(car)
		current_cars.append(car)

# ========================
# TIMER
# ========================
func _reset_timer() -> void:
	var t: float = base_time - (score * time_decrease_per_round)
	time_left = max(min_time, t)

# ========================
# CLEANUP
# ========================
func _clear_cars() -> void:
	for car in current_cars:
		if is_instance_valid(car):
			car.queue_free()
	
	current_cars.clear()

# ========================
# INTERACTION RESULT
# ========================
func on_player_chose_location(location: UsableLocation) -> void:
	if not is_round_active:
		return

	if location.is_location_valid():
		_on_correct_choice()
	else:
		_on_wrong_choice()

func _on_correct_choice() -> void:
	is_round_active = false
	next_round()

func _on_wrong_choice() -> void:
	is_round_active = false
	get_tree().reload_current_scene()

# ========================
# TIME OUT
# ========================
func _on_time_out() -> void:
	is_round_active = false
	get_tree().reload_current_scene()
