extends Node2D

@onready var rope = $Rope
@onready var bail_card_marker = $BailCard/Marker2D
@onready var anchor = $Anchor

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var target_modulate  = 0.25 + 0.75 * float(Gameplay.am_i_current_player() && !Gameplay.block_bail)
	modulate.a = Kinematics.dampf(modulate.a, target_modulate, 8.0, delta)

func update_rope():
	rope.points = [bail_card_marker.global_position - global_position, anchor.position]
