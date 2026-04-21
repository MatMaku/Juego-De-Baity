extends Node
class_name InteractionManager

# ========================
# REFERENCES
# ========================
@export var interaction_area: Area2D

var game_manager: Node = null

# ========================
# STATE
# ========================
var current_target: UsableLocation = null

# ========================
# INIT
# ========================
func _ready() -> void:
	# Conectar señales
	if interaction_area:
		interaction_area.area_entered.connect(_on_area_entered)
		interaction_area.area_exited.connect(_on_area_exited)
	else:
		push_warning("InteractionComponent: interaction_area no asignada")

	# 🔍 Buscar GameManager automáticamente
	game_manager = _find_game_manager()

	if game_manager == null:
		push_error("InteractionComponent: No se encontró GameManager en la escena")

# ========================
# INPUT
# ========================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	if current_target != null and game_manager != null:
		game_manager.on_player_chose_location(current_target)

# ========================
# DETECTION
# ========================
func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is UsableLocation:
		current_target = parent

func _on_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent == current_target:
		current_target = null

# ========================
# HELPERS
# ========================
func _find_game_manager() -> Node:
	# Opción 1: buscar por nombre (rápido y suficiente para tu caso)
	var root = get_tree().current_scene
	if root:
		return root.get_node_or_null("GameManager")

	return null
