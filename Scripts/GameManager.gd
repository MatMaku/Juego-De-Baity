extends Node

# ========================
# REFERENCES
# ========================
@export var player: Player
@export var player_spawn: Marker2D
@export var car_scene: PackedScene
@export var camera: Camera2D
@export var ui: UIController   # 🔥 NUEVO

# ========================
# STAGE CONFIG
# ========================
@export var spawn_containers: Array[Node2D]
@export var camera_zooms: Array[float]
@export var player_speeds: Array[float]

@export var zoom_lerp_speed: float = 10.0

# ========================
# TIMER CONFIG
# ========================
@export var base_time: float = 5.0
@export var time_decrease_per_round: float = 0.05
@export var min_time: float = 2.5

# ========================
# GAME CONFIG
# ========================
@export var initial_car_count: int = 2

# ========================
# STATE
# ========================
var current_cars: Array[UsableLocation] = []
var current_spawn_points: Array[Marker2D] = []

var score: int = 0
var current_car_count: int = 0

var time_left: float = 0.0
var current_round_time: float = 0.0   # 🔥 NUEVO (max real del round)

var is_round_active: bool = false

var current_stage: int = 0
var target_zoom: float = 1.0

# 🔥 OPTIMIZACIÓN (capacidades acumuladas)
var stage_capacities: Array[int] = []

# ========================
# INIT
# ========================
func _ready() -> void:
	_cache_stage_capacities()
	start_game()

# ========================
# LOOP
# ========================
func _process(delta: float) -> void:
	if is_round_active:
		time_left -= delta
		if time_left <= 0:
			_on_time_out()

	# 🔥 UI UPDATE
	if ui:
		ui.update_ui(score, time_left, current_round_time, delta)

	# Zoom suave
	if camera:
		var target := Vector2(target_zoom, target_zoom)
		camera.zoom = camera.zoom.lerp(target, zoom_lerp_speed * delta)

# ========================
# GAME FLOW
# ========================
func start_game() -> void:
	score = 0
	current_car_count = initial_car_count
	current_stage = 0
	
	_apply_stage()
	_start_round()

func next_round() -> void:
	score += 1
	current_car_count += 1
	
	_update_stage()
	_start_round()

func _start_round() -> void:
	is_round_active = true
	
	_reset_player()
	_clear_cars()
	_spawn_cars()
	_reset_timer()

# ========================
# STAGE SYSTEM
# ========================
func _update_stage() -> void:
	if stage_capacities.is_empty():
		return

	var current_capacity := stage_capacities[current_stage]

	if current_car_count > current_capacity:
		var next_stage := current_stage + 1
		next_stage = clamp(next_stage, 0, spawn_containers.size() - 1)

		if next_stage != current_stage:
			current_stage = next_stage
			_apply_stage()

func _apply_stage() -> void:
	_collect_spawn_points()

	# Cámara
	if current_stage < camera_zooms.size():
		target_zoom = camera_zooms[current_stage]

	# Velocidad
	if current_stage < player_speeds.size():
		player.speed = player_speeds[current_stage]

# ========================
# CACHE (CAPACIDAD ACUMULADA)
# ========================
func _cache_stage_capacities() -> void:
	stage_capacities.clear()

	var total := 0

	for container in spawn_containers:
		var count := 0
		
		for child in container.get_children():
			if child is Marker2D:
				count += 1
		
		total += count
		stage_capacities.append(total)

# ========================
# PLAYER
# ========================
func _reset_player() -> void:
	player.global_position = player_spawn.global_position
	player.velocity = Vector2.ZERO

# ========================
# SPAWN SYSTEM (ACUMULATIVO)
# ========================
func _collect_spawn_points() -> void:
	current_spawn_points.clear()

	for i in range(current_stage + 1):
		var container = spawn_containers[i]

		for child in container.get_children():
			if child is Marker2D:
				current_spawn_points.append(child)

func _spawn_cars() -> void:
	var available_points = current_spawn_points.duplicate()
	available_points.shuffle()

	var car_count: int = clamp(current_car_count, 1, current_spawn_points.size())
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
	current_round_time = max(min_time, t)   # 🔥 guardamos max real
	time_left = current_round_time

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
