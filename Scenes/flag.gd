extends Node2D

@onready var flag_sprite := $FlagPolygon
var raise_amount : float = 0.0
const flag_raise_height = 800.0

func _ready():
	position = get_screen_position()

func _process(delta: float) -> void:
	var desired_raise_position : float =  get_parent().get_node("Synchronizer").flag_raise_amount
	var new_raise_amount : float = Kinematics.dampf(raise_amount, desired_raise_position, 7.0, delta)
	position = get_screen_position() + Vector2(0.0, new_raise_amount * -get_flag_raise_height())
	flag_sprite.material.set_shader_parameter("inclination", Kinematics.dampf(flag_sprite.material.get_shader_parameter("inclination"), 23.0-60*sqrt(desired_raise_position), 4.0, delta))
	
	raise_amount = new_raise_amount
	
func get_screen_position() -> Vector2:
	return Global.game_size

func get_flag_raise_height() -> float:
	return Global.game_size.y * 0.4

func set_color():
	modulate = Values.get_color_light(Gameplay.current_player)
