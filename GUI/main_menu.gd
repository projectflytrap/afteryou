extends Control

var peer = ENetMultiplayerPeer.new()
var hosting : bool = false
var upnp : UPNP
const PORT = 9999
const MAX_PLAYERS = 4
var player_name = "Player" + str(randi() % 1000)  # Random name

@onready var ChatBox = %ChatBox

func _on_host_btn_pressed() -> void:
	var ret = Network.host(9999)
	if ret[0]:
		Global.add_chat_text(ret[1])
	else:
		Global.add_chat_text("Failed to Host.  " + ret[1])

func _on_join_btn_pressed() -> void:
	var query_ip = "127.0.0.1"
	if %IPAddressEdit.text != "":
		query_ip = %IPAddressEdit.text
	var ret = Network.connect_to_server(query_ip)
	if !ret[0]:
		#print(ret[1])
		Global.add_chat_text(ret[1])

func _on_line_edit_text_submitted(new_text: String) -> void:
	var t = new_text.strip_edges()
	if t != "":
		Network.rpc("chat_rpc", Global.get_colored_username(), new_text)
	%LineEdit.text = ""

func _on_username_edit_text_submitted(new_text: String) -> void:
	Global.username = new_text
	Global.add_chat_text("Username changed to " + new_text)


func _on_start_game_btn_pressed() -> void:
	if !Network.hosting:
		Global.add_chat_text("Cannot start lobby, not the host ")
		return
	Network.start_game()
	#get_tree().change_scene_to_file("res://Phases/main.tscn")
