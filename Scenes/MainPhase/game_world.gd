extends Node2D

@onready var equipment_card = preload("res://Scenes/EquipmentCard.tscn")


var equipment_scenes : Array = []
var equipment_radius : float = 500.0
var angle_offset : float = 0.0
var current_character : CharacterInfo


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var character = load("res://Characters/Wanderer/wanderer_info.tres")
	current_character = character
	spawn_character(character)
	$TargetingArrow.base = $MonsterCard
	Global.targeter = $TargetingArrow


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var middle_of_screen : Vector2 = get_middle()
	equipment_radius = min(middle_of_screen.x, middle_of_screen.y)-120.0
	var index = 0
	for x in equipment_scenes:
		var angle : float = TAU * index / equipment_scenes.size()
		var desired_location := middle_of_screen + (Vector2.UP * equipment_radius).rotated(angle_offset + angle)
		x.position = Kinematics.damp(x.position, desired_location, 3.0, delta)
		
		index+=1
	angle_offset += delta * 0.02
	

func spawn_character(character_info : CharacterInfo) -> void:
	equipment_scenes = []
	spawn_all_equipment(character_info)

func spawn_all_equipment(character_info : CharacterInfo) -> void:
	for i in character_info.equipment_list:
		spawn_equipment(i)

func spawn_equipment(equipment : Equipment) -> void:
	var new_equipment = equipment_card.instantiate()
	equipment_scenes.push_back(new_equipment)
	add_child(new_equipment)
	new_equipment.assign_info(equipment)
	

func get_middle() -> Vector2:
	return get_viewport().size * 0.5

func remove_equipment(eq):
	#angle_offset = randf_range(0.0, TAU)
	var ind = equipment_scenes.find(eq)
	equipment_scenes.remove_at(ind)
