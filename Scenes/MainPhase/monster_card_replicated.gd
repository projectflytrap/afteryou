extends Node2D
@onready var cardback = %MonsterCardBack
@export var wiggle_noise : FastNoiseLite
enum states {unrevealed, revealed, fade_out}
var state : states = states.unrevealed
var lifetime : float = 0.0
var home
const WIGGLE_STRENGTH : float = 40.0
const MIN_MOUSE_DIST : float = 100.0
const MAX_MOUSE_DIST : float = 500.0
func _ready():
	position = get_screen_position() + Vector2(0.0, -200.0)
	Global.targeter.base = self

func get_screen_position() -> Vector2:
	return Vector2(Global.game_size.x - cardback.size.x * 0.5 - 60.0, cardback.size.y * 0.5 + 60.0)

func _process(delta : float) -> void:
	lifetime += delta
	var desired_position : Vector2 = position
	var damp_lambda := 8.0
	
	cardback.material.set_shader_parameter("mouse_position", get_global_mouse_position())
	cardback.material.set_shader_parameter("sprite_position", position)
	match state:
		states.unrevealed:
			cardback.material.set_shader_parameter("border_glow_amount", 0.0)
			cardback.material.set_shader_parameter("alpha", Kinematics.dampf(cardback.material.get_shader_parameter("alpha"), 0.4 + 0.3*get_mouse_attraction(), 7.0, delta))
			var wiggle_amount : Vector2 = WIGGLE_STRENGTH * Vector2(0.5-wiggle_noise.get_noise_1d(lifetime*5.0), 0.5-wiggle_noise.get_noise_1d(-lifetime*5.0))
			desired_position = wiggle_amount + get_screen_position()
		states.fade_out:
			cardback.material.set_shader_parameter("border_glow_amount", 0.0)
			cardback.material.set_shader_parameter("overwrite_angle_amount", Kinematics.dampf(cardback.material.get_shader_parameter("overwrite_angle_amount"), 1.0, 7.0, delta))
			cardback.material.set_shader_parameter("alpha", Kinematics.dampf(cardback.material.get_shader_parameter("alpha"), 0.0, 3.0, delta))
			var destination : Vector2
			if home == null:
				desired_position = get_screen_position() + Vector2(0.0, -200.0)
			else:
				destination = home.global_position
			if cardback.material.get_shader_parameter("alpha") <= 0.05:
				queue_free()
	position = Kinematics.damp(position, desired_position, damp_lambda, delta)

func force_fade(target):
	state = states.fade_out
	home = target

func get_distance_to_mouse():
	return get_global_mouse_position().distance_to(get_screen_position())

func get_mouse_attraction() -> float:
	return clampf(remap(get_distance_to_mouse(),MIN_MOUSE_DIST,MAX_MOUSE_DIST,1.0,0.0), 0.0, 1.0)
