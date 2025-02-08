extends MarginContainer

func set_player(p_num : int):
	%UsernameLabel.add_theme_color_override("default_color", Values.get_color_main(p_num))
	%UsernameLabel.text = Gameplay.local_player_info[p_num].username

	var new_stylebox = %ProfilePanel.get_theme_stylebox("panel").duplicate()
	new_stylebox.border_color = Values.get_color_light(p_num)
	%ProfilePanel.add_theme_stylebox_override("panel", new_stylebox)
