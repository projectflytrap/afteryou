extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("_on_update_chat", _update_chat)
	_update_chat()

func _update_chat():
	text = Global.chat_text
	scroll_vertical = get_line_count()
