extends Node2D
class_name UsableLocation

# ========================
# STATE
# ========================
var is_valid: bool = false

# Y-SORT
@export var y_sort_offset: int = 0

# ========================
# SETUP
# ========================
func setup(valid: bool) -> void:
	is_valid = valid

# ========================
# GENERATION (override)
# ========================
func _generate() -> void:
	pass

# ========================
# LOOP
# ========================
func _process(_delta: float) -> void:
	_update_z_index()

# ========================
# Y SORT
# ========================
func _update_z_index() -> void:
	z_index = int(global_position.y) + y_sort_offset

# ========================
# PUBLIC API
# ========================
func is_location_valid() -> bool:
	return is_valid

func on_player_interact() -> bool:
	return is_valid
