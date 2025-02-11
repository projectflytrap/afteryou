extends Node2D

@onready var rope = $Rope
@onready var bail_card_marker = $BailCard/Marker2D
@onready var anchor = $Anchor

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	modulate.a = 0.5 + 0.5 * float(Gameplay.am_i_current_player())

func update_rope():
	rope.points = [bail_card_marker.global_position - global_position, anchor.position]
