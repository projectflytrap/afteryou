extends Node

var rand : RandomNumberGenerator = RandomNumberGenerator.new()
#Replicable effects will ALWAYS use rand.
var turn_order = []
var local_player_info = {}
enum game_phases {main}

var current_player : int = -1 #Nobody is going yet. Usually happens in reset game state.
var reveal_phase : bool = false
var game_phase = 0

func reset_game():
	if multiplayer.get_unique_id() != 1:
		return
	game_phase = game_phases.main
	current_player = -1

func end_turn(decision : MainPhaseDecision):
	if !am_i_current_player():
		print("Only the current player can end the turn.")
		return
	rpc_id(1, "end_current_turn", decision.to_dict())

@rpc("any_peer", "call_local")
func end_current_turn(decision):
	var sender_id = multiplayer.get_remote_sender_id()
	if multiplayer.get_unique_id() != 1:
		print("Warning: Unauthorized request from peer ", sender_id)
		return  # Ignore the request if it's not from the host
	if Network.player_data[sender_id].player_number != current_player:
		print("Only the current player can end their turn")
		return
	Network.reset_ready_protocol()
	rpc("replicate_end_turn_decision", decision)
	await Network._on_all_players_ready
	next_turn()

#####################################################################################
#WIP
@rpc("authority", "call_local")
func replicate_end_turn_decision(decision):
	var d : MainPhaseDecision = MainPhaseDecision.from_dict(decision)
	#REPEAT WHAT THE DECISION WAS!!!
	match d.intent:
		MainPhaseDecision.intents.bail:
			pass
		MainPhaseDecision.intents.remove_equipment:
			Global.main_scene.game_world.all_equipment[d.equipment_id].remove()
	#AWAIT THE DECISION TO FINISH FIRST.
	Network.rpc_id(1, "ready_protocol")


func next_turn():
	if multiplayer.get_unique_id() != 1:
		return
	#print("Host calling next_turn")
	increment_player()
	Global.main_scene.rpc("start_turn", current_player, get_pid_of_current_player())

func increment_player():
	#var old_player = current_player
	if current_player == -1:
		current_player = turn_order[0]
		return
	var index_of_current_player = turn_order.find(current_player)
	assert(index_of_current_player != -1, "Missing current player in turn order")
	current_player = turn_order[(index_of_current_player + 1) % get_player_count()]
	#print("Old player: ", old_player, " Current player: ", current_player)
	#WIP: Check if the current player is disconnected. Not sure what to do yet.
	#if Network.get_player_info_from_pnum(current_player).disconnected

func get_pid_of_current_player():
	for x in Network.player_data.keys():
		if Network.player_data[x].player_number == current_player:
			return x
	print("Could not find peer ID of current player")
	return -1

func get_player_numbers() -> Array[int]:
	var pnum : Array[int] = []
	for key in Network.player_data:
		pnum.append(Network.player_data[key].player_number)
	return pnum

func set_up_start_game() -> Dictionary:
	var s : int = initialize_random_values()
	var t_o : Array = randomize_turn_order()
	var serialized_player_info = compile_serialized_player_info()
	return {"seed" : s, "turn_order" : t_o, "player_info" : serialized_player_info}

func compile_serialized_player_info() -> Array: #Returns an array of player info. Only call if you are host!
	#Used by the host to send player info to all clients.
	var p_info = []
	for i in Network.player_data:
		p_info.append(Network.player_data[i].to_dict())
	return p_info

func overwrite_local_player_info(p_info):
	#var arr_info = PlayerInfo.from_dict(p_info)
	for i in p_info:
		var deserialized_info : PlayerInfo = PlayerInfo.from_dict(i)
		local_player_info[deserialized_info.player_number] = deserialized_info
	#print(local_player_info)

func initialize_random_values() -> int: #Returns the seed.
	randomize()
	var random_seed = randi()
	set_seed(random_seed)
	return random_seed

func set_seed(s : int):
	rand.set_seed(s)
	print("Seed set to ", s)

func randomize_turn_order() -> Array:
	var player_numbers := get_player_numbers()
	player_numbers.shuffle()
	return player_numbers

func get_turn_order_main_player_last() -> Array:
	#Returns the turn order such that the main player is last in the list.
	var index : int = turn_order.find(Global.player_number)  # Find the index of the player
	if index == -1:
		print("Bad, could not reorder player numbers because player number specified is missing.")
		return turn_order
	return turn_order.slice(index + 1) + turn_order.slice(0, index + 1)  # Rotate list

func get_player_count() -> int:
	return local_player_info.size()

func am_i_current_player() -> bool:
	return current_player == Global.player_number
