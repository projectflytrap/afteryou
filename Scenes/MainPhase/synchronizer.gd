extends Node
@export var current_target_index : int = -1
@export var flag_raise_amount : float = 0.0

func _set_targeting_index(ind : int):
	current_target_index = ind

func _set_flag_raise_amount(x : float):
	if Gameplay.am_i_current_player():
		flag_raise_amount = x
