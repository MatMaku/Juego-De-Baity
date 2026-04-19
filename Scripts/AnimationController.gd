extends Node2D

# ========================
# REFERENCES
# ========================
@export var sprite_body: NodePath
@export var shadow: NodePath
@export var player: NodePath
@export var dust_particles: NodePath
@export var sweat_particles: NodePath

# ========================
# CONFIG
# ========================
@export var bounce_speed: float = 12.0
@export var bounce_amount: float = 2.5
@export var tilt_amount: float = 5.0
@export var squash_amount: float = 0.05
@export var idle_lerp_speed: float = 10.0

# Debug / test
@export var sweat_enabled: bool = false

# ========================
# INTERNAL
# ========================
var _sprite: Sprite2D
var _shadow: Node2D
var _player: Player
var _dust: GPUParticles2D
var _sweat: GPUParticles2D

var time: float = 0.0
var was_moving: bool = false

# ========================
# INIT
# ========================
func _ready() -> void:
	_sprite = get_node(sprite_body) as Sprite2D
	_shadow = get_node(shadow) as Node2D
	_player = get_node(player) as Player
	_dust = get_node(dust_particles) as GPUParticles2D
	_sweat = get_node(sweat_particles) as GPUParticles2D

# ========================
# LOOP
# ========================
func _process(delta: float) -> void:
	time += delta
	_update_animation(delta)
	_update_particles()

# ========================
# ANIMATION
# ========================
func _update_animation(delta: float) -> void:
	var velocity: Vector2 = _player.get_current_velocity()
	var speed: float = _player.get_max_speed()
	var moving: bool = _player.is_moving()

	var speed_ratio: float = clamp(velocity.length() / speed, 0.0, 1.0)

	if moving:
		_apply_movement_animation(delta, velocity, speed_ratio)
	else:
		_apply_idle_animation(delta)

# ========================
# MOVEMENT ANIMATION
# ========================
func _apply_movement_animation(_delta: float, velocity: Vector2, speed_ratio: float) -> void:
	var bounce: float = sin(time * bounce_speed) * bounce_amount * speed_ratio
	_sprite.position.y = bounce

	_sprite.rotation_degrees = velocity.x * tilt_amount * 0.05

	if abs(velocity.x) > 5.0:
		_sprite.flip_h = velocity.x > 0

	var squash: float = 1.0 - abs(bounce) * squash_amount
	_sprite.scale = Vector2(1.0 + (1.0 - squash), squash)

	_shadow.scale = Vector2(1.0 - abs(bounce) * 0.15, 1.0)

# ========================
# IDLE
# ========================
func _apply_idle_animation(delta: float) -> void:
	_sprite.position.y = lerp(_sprite.position.y, 0.0, idle_lerp_speed * delta)
	_sprite.rotation_degrees = lerp(_sprite.rotation_degrees, 0.0, idle_lerp_speed * delta)
	_sprite.scale = _sprite.scale.lerp(Vector2.ONE, idle_lerp_speed * delta)
	_shadow.scale = _shadow.scale.lerp(Vector2.ONE, idle_lerp_speed * delta)

# ========================
# PARTICLES
# ========================
func _update_particles() -> void:
	var moving: bool = _player.is_moving()

	# 💨 Dust continuo
	if _dust:
		_dust.emitting = moving

	# 💦 Sweat
	if _sweat:
		_sweat.emitting = sweat_enabled
		
