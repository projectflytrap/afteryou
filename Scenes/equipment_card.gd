extends Node2D
@onready var cardback = %CardBack
@onready var delete = %Delete
var equipment : Equipment
const SELECTION_LENIENCY : float = 20.0
var lifetime := 0.0
var dead : bool = false
@onready var discarded_equipment = preload("res://Scenes/MainPhase/discarded_equipment.tscn")

func assign_info(info : Equipment):
	%Name.text = "[center]" + info.name
	%Effect.text = "[center]" + info.effect_text
	equipment = info
	var color : Color = Values.get_equipment_color(info.type)
	var new_stylebox = %NamePanel.get_theme_stylebox("panel").duplicate()
	new_stylebox.bg_color.r = color.r
	new_stylebox.bg_color.g = color.g
	new_stylebox.bg_color.b = color.b
	%NamePanel.add_theme_stylebox_override("panel", new_stylebox)
	%CardBack.material.set_shader_parameter("inner_border_color", color)
	%CardBack.material.set_shader_parameter("background_color", get_parent().current_character.equipment_color)

func _process(delta: float) -> void:
	if dead:
		return
	var is_target : bool = Global.targeter && Global.targeter.target == self
	lifetime += delta
	if is_target && Input.is_action_just_pressed("Click"):
		kms()
	cardback.material.set_shader_parameter("border_glow_amount", Kinematics.dampf(cardback.material.get_shader_parameter("border_glow_amount"), float(is_target), 8.0, delta))
	delete.modulate.a = (1.0+sin(lifetime*5.0))*0.5 * float(is_target)

func check_valid_target():
	var mouse_in = mouse_inside()
	var targeter = Global.targeter
	if !mouse_in:
		return
	if targeter.target == null:
		targeter.target = self
	else:
		var dist_to_target = get_global_mouse_position().distance_squared_to(position)
		var current_dist_to_target = get_global_mouse_position().distance_squared_to(targeter.target.position)
		if dist_to_target < current_dist_to_target:
			targeter.target = self

func mouse_inside():
	var mp : = get_global_mouse_position() - position
	mp = mp.abs()
	var sz : Vector2 = Vector2(195.0, 195.0) * 0.5
	sz += Vector2(SELECTION_LENIENCY, SELECTION_LENIENCY)
	return mp.x <= sz.x && mp.y <= sz.y

func kms():
	var my_limp_corpse = discarded_equipment.instantiate()
	get_parent().add_child(my_limp_corpse)
	my_limp_corpse.position = position
	get_parent().remove_equipment(self)
	cardback.material.set_shader_parameter("border_glow_amount", 1.0)
	cardback.material.set_shader_parameter("darken", 0.7)
	
	delete.modulate.a = 0.0
	remove_from_group("Targetable")
	Global.targeter.target = null
	dead = true
	await get_tree().physics_frame
	get_parent().remove_child(self)
	my_limp_corpse.add_child(self)
	position = Vector2.ZERO
	cardback.material.set_shader_parameter("border_glow_amount", 0.0)
	delete.modulate.a = 0.0
	
