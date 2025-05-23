extends MarginContainer

@onready var animation_player = $AnimationPlayer
var active = false
var player_number : int

func set_player(p_num : int):
	%UsernameLabel.add_theme_color_override("default_color", Values.get_color_main(p_num))
	%UsernameLabel.text = Gameplay.local_player_info[p_num].username
	player_number = p_num
	var new_stylebox = %ProfilePanel.get_theme_stylebox("panel").duplicate()
	new_stylebox.border_color = Values.get_color_light(p_num)
	%ProfilePanel.add_theme_stylebox_override("panel", new_stylebox)

func _set_turn_indicator():
	if player_number == Gameplay.current_player:
		animation_player.play("Start_Turn")
		active = true
		return
	if active:
		animation_player.play("End_Turn")
		active = false

func set_bail(p_num : int, bail : bool):
	if player_number == p_num:
		%ProfilePanel.modulate.a = 0.3 + 0.7 * float(!bail)
