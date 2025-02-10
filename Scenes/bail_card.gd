extends RigidBody2D

var held := false
var mouse_in := false
var click_offset : Vector2

@onready var marker = $Marker2D
@onready var anchor = get_parent().get_node("Anchor")
const max_distance : float = 500.0

func _physics_process(delta):
	#print(Global.held_object == null && mouse_in)
	#print(Input.is_action_pressed("click"))
	var distance = global_position.distance_to(anchor.global_position)
	if held:
		global_transform.origin = get_global_mouse_position() + click_offset
		global_rotation = lerp_angle(global_rotation, (anchor.global_position - global_position).angle(), delta * 12.0)
		if Input.is_action_just_released("Click"):
			drop()
			if distance > max_distance:
				linear_velocity = Vector2.ZERO
				angular_velocity = 0.0
				#apply_central_force(-mass * linear_velocity * 0.5 * delta)
	# Calculate the direction and distance between anchor and marker
	var direction = (global_position - anchor.global_position).normalized()
	distance = global_position.distance_to(anchor.global_position)
	if distance > max_distance:
		global_transform.origin = anchor.global_position + direction * max_distance
func pickup():
	if held:
		return
	freeze = true
	held = true
	gravity_scale = 0.0
	
func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false
		Global.held_object = null
		gravity_scale = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_offset = Vector2(randf_range(-300, 300), randf_range(-300, 300))
	apply_impulse(Vector2.UP.rotated(randf_range(-PI/3, PI/3)) * randf_range(300.0, 700.0), random_offset)
	Global.held_object = null

func _on_mouse_entered() -> void:
	mouse_in = true

func _on_mouse_exited() -> void:
	mouse_in = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed && Global.held_object == null:
			pickup()
			click_offset = global_transform.origin - event.global_position
