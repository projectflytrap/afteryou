extends TextEdit


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("Chat",):
			if has_focus():
				var t : String = text.strip_edges()
				if t == "":
					return
				Network.rpc("chat_rpc", Global.get_colored_username(), t)
				release_focus()
				text = ""
			else:
				grab_focus()
				get_viewport().set_input_as_handled()
				#text = text.strip_edges(true, false)
