extends Node

var peer = ENetMultiplayerPeer.new()
var hosting : bool = false
var upnp : UPNP
var game_in_progress = false
var player_data = {}
const PORT = 9999
const MAX_PLAYERS = 4

func host(port : int) -> Array: #Returns array, where the first element is a bool based on success, and the second element is the error message.
	hosting = true
	upnp = UPNP.new()
	var discover_result = upnp.discover()
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var map_result_udp = upnp.add_port_mapping(9999, 0, "gd_udp", "UDP", 0)
			var map_result_tcp = upnp.add_port_mapping(9999, 0, "gd_tcp", "TCP", 0)
		else:
			return [false, "Failed to get UPNP gateway. Check your router UPNP settings."]
	else:
		return [false, "Failed to discover UPNP devices."]
	var external_ip = upnp.query_external_address()
	print(external_ip)
	#ChatBox.text = str("hosting server on external ip : ", external_ip, " on port ", "9999", "\n")
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error == OK:
		multiplayer.multiplayer_peer = peer
	elif error == ERR_ALREADY_IN_USE:
		return [false, "You are already hosting."]
	else:
		return [false, "Failed to host."]
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	var new_player_info : PlayerInfo = PlayerInfo.new()
	new_player_info.username = Global.username
	player_data = {multiplayer.get_unique_id():new_player_info}
	Global.player_number = 0
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	#print("Server started on port", PORT)
	return [true, str("Server started at ", external_ip, ":", port)]

func connect_to_server(ip_address: String) -> Array:
	var error = peer.create_client(ip_address, PORT)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Connecting to server at ", ip_address, " on port ", PORT)
		return [true, ""]
	elif error == ERR_ALREADY_IN_USE:
		return [false, str("Failed to connect to server at ", ip_address, " on port ", PORT, ": Player has already created client")]
	else:
		return [false, str("Failed to connect to server at ", ip_address, " on port ", PORT)]

func _on_player_connected(peer_id):
	print("Player ", peer_id, " connected")
	if game_in_progress && hosting:
		print("Rejecting connection from player ", peer_id, " because the game has already started.")
		reject_player("Game already in progress", peer_id)
		return
	elif multiplayer.get_peers().size() >= MAX_PLAYERS:
		print("Rejecting player", peer_id, "because the lobby is full.")
		reject_player("Lobby is full", peer_id)
		return
	#rpc("broadcast","Player %d has joined." % peer_id)
	#Assign new player player resources.
	var new_player_info : PlayerInfo = PlayerInfo.new()
	new_player_info.player_number = get_unused_player_number()
	player_data[peer_id] = new_player_info	
	rpc_id(peer_id, "request_player_info", new_player_info.player_number)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if hosting:
			upnp.delete_port_mapping(9999, "UDP")
			upnp.delete_port_mapping(9999, "TCP")
			print("Deleted port mappings")
		get_tree().quit()


#Chat functionality
@rpc("any_peer", "call_local")
func chat_rpc(p : String, data : String):
	Global.add_chat_text(str(p,": ",data))

@rpc("any_peer", "call_local")
func broadcast(data : String):
	Global.add_chat_text(data)

@rpc("authority")  # Ensure only the server can call this
func reject_player(reason: String, player_id: int):
	rpc_id(player_id, "receive_rejection", reason)
	await get_tree().create_timer(0.5).timeout  # Give the client time to receive the message
	multiplayer.disconnect_peer(player_id)

@rpc("any_peer", "call_local")
func receive_rejection(reason: String):
	print("Rejection Received")
	Global.add_chat_text("Connection rejected: " + reason)
	multiplayer.multiplayer_peer = null

@rpc("authority")
func start_game():
	if multiplayer.get_unique_id() != 1:  # Ensure only the host (peer 1) can start
		print("Unauthorized attempt to start the game!")
		return
	if game_in_progress:
		print("Game already in progress!")
		return
	var set_up_values = Gameplay.set_up_start_game()
	game_in_progress = true
	print("Game started!")
	# Notify all clients that the game has started
	rpc("on_game_started", set_up_values)


@rpc("any_peer", "call_local")
func on_game_started(set_up_values):
	Global.set_chat_text("The game has started!")
	game_in_progress = true
	Gameplay.set_seed(set_up_values["seed"])
	Gameplay.turn_order = set_up_values["turn_order"]
	get_tree().change_scene_to_file("res://Phases/main.tscn")


@rpc("authority")
func request_player_info(received_player_number : int): #Received by the client from the server. Request player info from the player. Also receive a player number.
	#print("my id is :" , multiplayer.get_unique_id())
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id != 1:
		print("Warning: Unauthorized request from peer ", sender_id)
		return  # Ignore the request if it's not from the host
	Global.player_number = received_player_number
	#print("My new player number is ", received_player_number)
	#print("request_player_info_called")
	var send_player_info : PlayerRequestInfo = PlayerRequestInfo.new()
	send_player_info.username = Global.username
	rpc_id(1, "receive_player_info", send_player_info.to_dict())
	#print("Sent player info to host:", send_player_info)


@rpc("any_peer", "call_local")
func receive_player_info(player_request_info):
	var sender_id = multiplayer.get_remote_sender_id()
	# Update player data (assuming `player_data` is a dictionary)
	player_data[sender_id].update(PlayerRequestInfo.from_dict(player_request_info))
	var p_info_username = player_data[sender_id].username
	rpc("broadcast","Player %s has joined." % p_info_username)
	#print("Updated player data for peer:", sender_id)


func get_unused_player_number() -> int:
	var taken_player_numbers = []
	for i in player_data.keys():
		taken_player_numbers.push_back(player_data[i].player_number)
	#print("Taken player numbers: " + str(taken_player_numbers))
	for i in range(MAX_PLAYERS):
		if !taken_player_numbers.has(i):
			print("Assigned player number : ", i)
			return i
	return 0
