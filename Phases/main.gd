extends Control

@onready var main_player_icon = %PlayerIconBig
@onready var player_icon_vbox = %PlayerIconVbox
@onready var player_icon = preload("res://GUI/PlayerIcons.tscn")

var player_icons = {}
#Access using player number as keys.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_players()

func initialize_players():
	for i in Gameplay.local_player_info.size() - 1:
		var new_player_icon = player_icon.instantiate()
		player_icon_vbox.add_child(new_player_icon)
	var relative_turn_order = Gameplay.get_turn_order_main_player_last()
	var last_player = relative_turn_order.pop_back()
	assert(last_player == Global.player_number, "Error: Missing current player in turn order.")
	var index : int = 0
	for i in relative_turn_order:
		var current_player_icon = player_icon_vbox.get_children()[index]
		current_player_icon.set_player(i)
		index += 1
		player_icons[i] = current_player_icon
	main_player_icon.set_player(Global.player_number)
	player_icons[Global.player_number] = main_player_icon
