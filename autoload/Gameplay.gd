extends Node

var rand : RandomNumberGenerator = RandomNumberGenerator.new()
#Replicable effects will ALWAYS use rand.
var turn_order = []

func get_player_numbers() -> Array[int]:
	var pnum : Array[int] = []
	for key in Network.player_data:
		pnum.append(Network.player_data[key].player_number)
	return pnum

func set_up_start_game() -> Dictionary:
	var seed : int = initialize_random_values()
	var turn_order : Array = randomize_turn_order()
	return {"seed" : seed, "turn_order" : turn_order}

func initialize_random_values() -> int: #Returns the seed.
	randomize()
	var random_seed = randi()
	#set_seed(random_seed)
	return random_seed

func set_seed(seed : int):
	rand.set_seed(seed)
	print("Seed set to ", seed)

func randomize_turn_order() -> Array:
	var player_numbers := get_player_numbers()
	player_numbers.shuffle()
	return player_numbers
