extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_offset = Vector2(randf_range(-300, 300), randf_range(-300, 300))
	apply_impulse(Vector2.UP.rotated(randf_range(-PI/3, PI/3)) * randf_range(300.0, 700.0), random_offset)
