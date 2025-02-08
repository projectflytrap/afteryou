extends Node

var rand : RandomNumberGenerator = RandomNumberGenerator.new()
#Replicable effects will ALWAYS use rand.
var turn_order = []
var local_player_info = {}

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
