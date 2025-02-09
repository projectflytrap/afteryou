extends Node2D

@onready var cardback = %MonsterCardBack
@onready var cardfront = %CardFront
@onready var cardfrontstock = %CardFrontStock
enum states {unselected, flipping, revealed}
#Unselected, is when the player hasn't selected the card yet.
#flipping is while the player is still selecting the card.
@export var wiggle_noise : FastNoiseLite
var state = states.unselected
var lifetime : float = 0.0
var click_offset : Vector2 = Vector2.ZERO
var selection_location : Vector2 = Vector2.ZERO #Where the card was clicked initially.
const FLIP_DISTANCE : float = 300.0
const WIGGLE_STRENGTH : float = 40.0
const SELECTION_LENIENCY : float = 0.0
const MIN_MOUSE_DIST : float = 100.0
const MAX_MOUSE_DIST : float = 350.0
const COLOR_ATTRACTED : Color = Color(0, 0.933, 0.208)
const COLOR_FLIPPING_NONE : Color = Color(0.94, 0.898, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(mouse_in_card())
	lifetime += delta
	var desired_position : Vector2 = position
	var damp_lambda := 3.0
	match state:
		states.unselected:
			cardfrontstock.hide()
			cardback.show()
			cardfront.hide()
			var mouse_attraction : float = get_mouse_attraction()
			var wiggle_amount : Vector2 = WIGGLE_STRENGTH * Vector2(0.5-wiggle_noise.get_noise_1d(lifetime*5.0), 0.5-wiggle_noise.get_noise_1d(-lifetime*5.0))
			wiggle_amount *= 1.0 - mouse_attraction
			desired_position = wiggle_amount + get_screen_position()
			desired_position = lerp(desired_position, get_global_mouse_position(), 0.3 * mouse_attraction)
			if mouse_in_card() && Input.is_action_just_pressed("Click"):
				state = states.flipping
				click_offset = position - get_global_mouse_position()
				selection_location = get_global_mouse_position()
			else:
				click_offset = Vector2.ZERO
			var max_tilt : float = 0.1+0.3*mouse_attraction
			cardback.material.set_shader_parameter("max_tilt", Kinematics.dampf(cardback.material.get_shader_parameter("max_tilt"), max_tilt, 2.0, delta))
			var border_glow_amount : float = pow(mouse_attraction, 2)
			cardback.material.set_shader_parameter("border_glow_amount", Kinematics.dampf(cardback.material.get_shader_parameter("border_glow_amount"), border_glow_amount, 4.0, delta))
			cardback.material.set_shader_parameter("border_glow_color", COLOR_ATTRACTED)
			cardback.material.set_shader_parameter("overwrite_angle_amount", Kinematics.dampf(cardback.material.get_shader_parameter("overwrite_angle_amount"), 0.0, 6.0, delta))
			cardback.material.set_shader_parameter("mouse_position", get_global_mouse_position() + click_offset)
			cardback.material.set_shader_parameter("sprite_position", position)
		states.flipping:
			cardback.show()
			cardfront.hide()
			if not Input.is_action_pressed("Click"):
				state = states.unselected
			desired_position = get_global_mouse_position() + click_offset
			damp_lambda = 8.0
			var max_tilt : float = 1.0
			cardback.material.set_shader_parameter("max_tilt", Kinematics.dampf(cardback.material.get_shader_parameter("max_tilt"), max_tilt, 2.0, delta))
			var flip_amount : float = get_flip_amount()
			var border_glow_amount : float = 0.3 + 0.7*flip_amount
			var border_glow_color = lerp(COLOR_FLIPPING_NONE, COLOR_ATTRACTED, flip_amount)
			if cardback.material.get_shader_parameter("overwrite_angle_amount") >= 0.995:
				Global.targeter.base = self
				Global.targeter.targeting = true
				state = states.revealed
				cardback.hide()
				cardfront.modulate.a = 0.0
				cardfront.position.y = 0.0
				cardfrontstock.material.set_shader_parameter("overwrite_angle_amount", 1.0)
			cardback.material.set_shader_parameter("overwrite_angle_amount", Kinematics.dampf(cardback.material.get_shader_parameter("overwrite_angle_amount"), pow(flip_amount,0.5), 30.0, delta))
			cardback.material.set_shader_parameter("border_glow_amount", Kinematics.dampf(cardback.material.get_shader_parameter("border_glow_amount"), border_glow_amount, 4.0, delta))
			cardback.material.set_shader_parameter("border_glow_color", Kinematics.damp(cardback.material.get_shader_parameter("border_glow_color"), border_glow_color, 2.0, delta))
			cardback.material.set_shader_parameter("mouse_position", get_global_mouse_position() + click_offset)
			cardback.material.set_shader_parameter("sprite_position", position)
		states.revealed:
			cardfront.show()
			cardfrontstock.show()
			cardfrontstock.material.set_shader_parameter("overwrite_angle_amount", Kinematics.dampf(cardfrontstock.material.get_shader_parameter("overwrite_angle_amount"), 0.0, 2.5, delta))
			damp_lambda = 4.0
			cardfront.position.y = Kinematics.dampf(cardfront.position.y, -130.0, 3.0, delta)
			cardfront.modulate.a = Kinematics.dampf(cardfront.modulate.a, 1.0, 3.0, delta)
			var wiggle_amount : Vector2 = WIGGLE_STRENGTH * 0.6 * Vector2(0.5-wiggle_noise.get_noise_1d(lifetime*5.0), 0.5-wiggle_noise.get_noise_1d(-lifetime*5.0))
			desired_position = wiggle_amount + get_screen_position()
			cardfrontstock.material.set_shader_parameter("mouse_position", get_global_mouse_position())
			cardfrontstock.material.set_shader_parameter("sprite_position", position)
			cardfrontstock.material.set_shader_parameter("max_tilt", 0.1)
	position = Kinematics.damp(position, desired_position, damp_lambda, delta)


func mouse_in_card():
	var mp : = get_global_mouse_position() - position
	mp = mp.abs()
	var sz : Vector2 = cardback.size * 0.5
	sz += Vector2(SELECTION_LENIENCY, SELECTION_LENIENCY)
	return mp.x <= sz.x && mp.y <= sz.y

func get_distance_to_mouse():
	return get_global_mouse_position().distance_to(get_screen_position())

func get_flip_distance():
	return get_global_mouse_position().distance_to(selection_location)

func get_flip_amount():
	return clampf(remap(get_flip_distance(),0.0,FLIP_DISTANCE,0.0,1.0), 0.0, 1.0)

func get_mouse_attraction() -> float:
	return clampf(remap(get_distance_to_mouse(),MIN_MOUSE_DIST,MAX_MOUSE_DIST,1.0,0.0), 0.0, 1.0)

func get_screen_position() -> Vector2:
	return Vector2(get_viewport().size.x - cardback.size.x * 0.5 - 60.0, cardback.size.y * 0.5 + 60.0)
