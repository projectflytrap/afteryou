extends Control

@onready var main_player_icon = %PlayerIconBig
@onready var player_icon_vbox = %PlayerIconVbox
@onready var your_turn_banner = $YourTurnBanner
@onready var game_world = $GameWorld
@onready var player_icon = preload("res://GUI/PlayerIcons.tscn")


var player_icons = {}
#Access using player number as keys.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.main_scene = self
	initialize_players()
	if multiplayer.get_unique_id() == 1:
		Gameplay.reset_game()
		wait_to_ready_start_game()

#func _process(_delta : float) -> void:
	#pass
	##print(get_global_mouse_position())

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

func wait_to_ready_start_game():
	await Network._on_all_players_ready
	Gameplay.next_turn()


@rpc("authority", "call_local")
func start_turn(new_current_player, current_player_pid):
	Gameplay.current_player = new_current_player
	set_player_icon_turn()
	Global.targeter.update_color_to_current_player()
	get_tree().call_group("Flag", "set_color")
	if new_current_player == Global.player_number:
		#It is OUR TURN
		start_my_turn()
	else:
		#IT is NOT our turn.
		start_other_turn()
	Global.targeter.visualized_target = -1
	Global.targeter.active = false
	for i in get_tree().get_nodes_in_group("Synchronizer"):
		i.set_multiplayer_authority(current_player_pid)
		i.current_target_index = -1

func start_my_turn():
	your_turn_banner._play_your_turn_animation()
	game_world.draw_interactable_card()
	if game_world.has_replicated_monster_card:
		game_world.force_fade_replicated_monster_card(null)
	#Global.add_chat_text("Starting my turn")

func start_other_turn():
	if not game_world.has_replicated_monster_card:
		game_world.spawn_replicated_monster_card()
	#Global.add_chat_text("Starting other player's turn: " + str(Gameplay.current_player))

func set_player_icon_turn():
	get_tree().call_group("PlayerIcon", "_set_turn_indicator")
