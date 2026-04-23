extends UsableLocation

# ========================
# REFERENCES
# ========================
@onready var body_closed: Sprite2D = $CarColor
@onready var body_open: Sprite2D = $CarColorOpen

@onready var front_normal: Sprite2D = $CarFront
@onready var front_light: Sprite2D = $CarFrontLight

@onready var back_closed: Sprite2D = $CarBack
@onready var back_open: Sprite2D = $CarBackOpen

# ========================
# STATE
# ========================
var door_open: bool = false
var light_on: bool = false
var facing_right: bool = false

# ========================
# INIT SAFETY
# ========================
func _ready() -> void:
	# Estado base consistente
	body_closed.visible = true
	body_open.visible = false

	front_normal.visible = true
	front_light.visible = false

	back_closed.visible = true
	back_open.visible = false

	_generate()

# ========================
# GENERATION
# ========================
func _generate() -> void:
	_randomize_color()
	_randomize_direction()

	if is_valid:
		_generate_valid()
	else:
		_generate_invalid()

	_apply_visuals()

# ========================
# VALID / INVALID
# ========================
func _generate_valid() -> void:
	door_open = true
	light_on = false

func _generate_invalid() -> void:
	while true:
		door_open = randf() < 0.5
		light_on = randf() < 0.5

		if not (door_open and not light_on):
			break

# ========================
# DIRECTION
# ========================
func _randomize_direction() -> void:
	facing_right = randf() < 0.5

# ========================
# VISUALS
# ========================
func _apply_visuals() -> void:
	# BODY (depende de la puerta)
	body_closed.visible = not door_open
	body_open.visible = door_open

	# FRONT
	front_normal.visible = not light_on
	front_light.visible = light_on

	# BACK
	back_closed.visible = not door_open
	back_open.visible = door_open

	# DIRECCIÓN (flip horizontal)
	scale.x = 1 if facing_right else -1

# ========================
# COLOR
# ========================
func _randomize_color() -> void:
	var color: Color = _get_random_color()

	body_closed.modulate = color
	body_open.modulate = color

func _get_random_color() -> Color:
	var colors: Array[Color] = [
		Color(1, 0.2, 0.2),
		Color(0.2, 0.6, 1),
		Color(0.2, 1, 0.4),
		Color(1, 1, 0.3),
		Color(0.8, 0.8, 0.8)
	]
	return colors.pick_random()
