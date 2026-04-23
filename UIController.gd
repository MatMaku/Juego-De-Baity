extends CanvasLayer
class_name UIController

# ========================
# REFERENCES
# ========================
@export var score_label: Label
@export var time_bar: ColorRect

# ========================
# CONFIG
# ========================
@export var shake_intensity_max: float = 6.0
@export var low_time_threshold: float = 0.5

@export var pulse_strength: float = 0.25
@export var pulse_speed: float = 12.0

# ========================
# STATE
# ========================
var max_time: float = 1.0
var current_time: float = 1.0

var base_position: Vector2
var time_accum: float = 0.0

# ========================
# INIT
# ========================
func _ready() -> void:
	base_position = time_bar.position

# ========================
# UPDATE (llamado desde GameManager)
# ========================
func update_ui(score: int, time_left: float, max_time_value: float, delta: float) -> void:
	score_label.text = str(score)

	current_time = time_left
	max_time = max_time_value

	var ratio: float = clamp(time_left / max_time_value, 0.0, 1.0)

	_update_time_bar(ratio, delta)

# ========================
# TIME BAR
# ========================
func _update_time_bar(ratio: float, delta: float) -> void:
	# Escala horizontal (tiempo)
	time_bar.scale.x = ratio

	# 🔥 COLOR PROGRESIVO (verde → amarillo → rojo)
	time_bar.color = _get_color_from_ratio(ratio)

	# 🔥 EFECTOS
	if ratio < low_time_threshold:
		_apply_effects(ratio, delta)
	else:
		_reset_effects()

# ========================
# COLOR
# ========================
func _get_color_from_ratio(ratio: float) -> Color:
	# 0 → rojo
	# 0.5 → amarillo
	# 1 → verde
	
	if ratio > 0.5:
		# Verde → amarillo
		var t = (ratio - 0.5) * 2.0
		return Color(1.0 - t, 1.0, 0.0)
	else:
		# Amarillo → rojo
		var t = ratio * 2.0
		return Color(1.0, t, 0.0)

# ========================
# EFFECTS
# ========================
func _apply_effects(ratio: float, delta: float) -> void:
	var intensity = 1.0 - ratio

	# 🔥 SHAKE
	var shake_strength = shake_intensity_max * intensity

	var offset = Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength) * 0.5
	)

	time_bar.position = base_position + offset

	# 🔥 PULSE (escala vertical)
	time_accum += delta * pulse_speed

	var pulse = sin(time_accum) * pulse_strength * intensity

	time_bar.scale.y = 1.0 + pulse

# ========================
# RESET
# ========================
func _reset_effects() -> void:
	time_bar.position = base_position
	time_bar.scale.y = 1.0
	time_accum = 0.0
