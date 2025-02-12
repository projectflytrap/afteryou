extends RigidBody2D

var held := false
var mouse_in := false
var click_offset : Vector2

@onready var marker = $Marker2D
@onready var bail_sprite = $BailCard
@onready var anchor = get_parent().get_node("Anchor")
@export var success_image : Texture
@export var normal_image : Texture
const max_distance : float = 500.0
const MIN_MOUSE_DIST : float = 100.0
const MAX_MOUSE_DIST : float = 700.0
const player_mouse_near : Color = Color(0.95, 0.786, 0)
const player_mouse_far : Color = Color(1, 0.162, 0.314)
const player_hold_near : Color = Color(0.432, 0.346, 1)
const player_hold_far : Color = Color(0, 0.66, 0.209)
const player_hold_done : Color = Color(0.319, 0.969, 0)

func _physics_process(delta):
	#print(Global.held_object == null && mouse_in)
	#print(Input.is_action_pressed("click"))
	var distance = global_position.distance_to(anchor.global_position)
	if Gameplay.am_i_current_player() && !Gameplay.block_bail:
		if held:
			global_transform.origin = get_global_mouse_position() + click_offset
			global_rotation = lerp_angle(global_rotation, (anchor.global_position - global_position).angle(), delta * 12.0)
			bail_sprite.material.set_shader_parameter("border_glow_amount", Kinematics.dampf(bail_sprite.material.get_shader_parameter("border_glow_amount"), 1.0, 12.0, delta))
			var rec_dist := global_position.distance_to(anchor.global_position)
			get_tree().call_group("Synchronizer", "_set_flag_raise_amount", clampf(inverse_lerp(0.0, max_distance, rec_dist), 0.0, 1.0))
			if rec_dist >= max_distance:
				bail_sprite.material.set_shader_parameter("border_glow_amount", 1.0)
				bail_sprite.material.set_shader_parameter("border_glow_color", player_hold_done)
				bail_sprite.texture = success_image
			else:
				bail_sprite.texture = normal_image
				bail_sprite.material.set_shader_parameter("border_glow_amount", Kinematics.dampf(bail_sprite.material.get_shader_parameter("border_glow_amount"), 0.4+0.4*inverse_lerp(0.0, max_distance, rec_dist), 6.0, delta))
				bail_sprite.material.set_shader_parameter("border_glow_color", lerp(player_hold_near, player_hold_far, inverse_lerp(0.0, max_distance, rec_dist)))
			if Input.is_action_just_released("Click"):
				drop()
				Gameplay.block_action_type = MainPhaseDecision.intents.none
				if rec_dist >= max_distance:
					linear_velocity = Vector2.ZERO
					angular_velocity = 0.0
					end_turn()
					Gameplay.block_action_turn = true
		else:
			get_tree().call_group("Synchronizer", "_set_flag_raise_amount", 0.0)
			bail_sprite.texture = normal_image
			bail_sprite.material.set_shader_parameter("border_glow_amount", Kinematics.dampf(bail_sprite.material.get_shader_parameter("border_glow_amount"), get_mouse_attraction()*0.7, 6.0, delta))
			bail_sprite.material.set_shader_parameter("border_glow_color", lerp(player_mouse_far, player_mouse_near, get_mouse_attraction()))
	else:
		#if Gameplay.am_i_current_player():
			#block_input = false
		held = false
		bail_sprite.material.set_shader_parameter("border_glow_amount", Kinematics.dampf(bail_sprite.material.get_shader_parameter("border_glow_amount"), 0.0, 5.0, delta))
	# Calculate the direction and distance between anchor and marker
	var direction = (global_position - anchor.global_position).normalized()
	distance = global_position.distance_to(anchor.global_position)
	if distance > max_distance:
		global_transform.origin = anchor.global_position + direction * max_distance
	get_parent().update_rope()

func pickup():
	if held:
		return
	if !Gameplay.is_unblocked(MainPhaseDecision.intents.bail) || Gameplay.block_bail:
		return
	freeze = true
	held = true
	gravity_scale = 0.0
	Gameplay.block_action_type = MainPhaseDecision.intents.bail
	
func drop(impulse=Vector2.ZERO):
	if held:
		
		freeze_mode = FreezeMode.FREEZE_MODE_STATIC
		freeze = false
		apply_central_impulse(impulse)
		held = false
		Global.held_object = null
		gravity_scale = 1.0
		freeze_mode = FreezeMode.FREEZE_MODE_KINEMATIC

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

func get_distance_to_mouse() -> float:
	return get_global_mouse_position().distance_to(global_position)

func get_mouse_attraction() -> float:
	return clampf(remap(get_distance_to_mouse(),MIN_MOUSE_DIST,MAX_MOUSE_DIST,1.0,0.0), 0.0, 1.0)

func end_turn():
	var decision : MainPhaseDecision = MainPhaseDecision.new()
	decision.intent = MainPhaseDecision.intents.bail
	Gameplay.end_turn(decision)
