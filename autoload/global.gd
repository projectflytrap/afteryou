extends Node

signal _on_update_chat

var username : String :
	get:
		if username == "":
			return "NO_NAME"
		return username

var chat_text : String = ""
var player_number : int = -1
var targeter
var held_object
var game_size = Vector2(1920,1080)
var main_scene : Node

func add_chat_text(inp : String):
	if chat_text != "":
		chat_text += "\n"
	chat_text += inp
	emit_signal("_on_update_chat")

func set_chat_text(inp : String):
	chat_text = inp
	emit_signal("_on_update_chat")

func get_bb_code_wrapped_color(color : Color, data : String) -> String:
	return "[color=#" + color.to_html() + "]" + data + "[/color]"

func get_colored_username() -> String:
	return get_bb_code_wrapped_color(Values.get_color_main(player_number), username)
