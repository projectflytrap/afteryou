extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var col = Values.get_color_main(Global.player_number)
	%BackgroundColor.color.r = col.r
	%BackgroundColor.color.g = col.g
	%BackgroundColor.color.b = col.b

func _play_your_turn_animation():
	$AnimationPlayer.play("Flash")
