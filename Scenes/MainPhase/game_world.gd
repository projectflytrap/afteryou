extends Node2D

@onready var equipment_card = preload("res://Scenes/EquipmentCard.tscn")

var equipment_scenes : Array = []
var all_equipment : Array = []
var equipment_radius : float = 500.0
var angle_offset : float = 0.0
var current_character : CharacterInfo
var has_replicated_monster_card : bool = false
var current_replicated_monster_card
@onready var monster_card_replica = preload("res://Scenes/MainPhase/monster_card_replicated.tscn")
@onready var monster_card = preload("res://Scenes/MonsterCard.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var character = load("res://Characters/Wanderer/wanderer_info.tres")
	current_character = character
	spawn_character(character)
	Global.targeter = $TargetingArrow
	Global.held_object = null
	
	await get_tree().create_timer(0.5).timeout 
	Network.rpc_id(1, "ready_protocol")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var middle_of_screen : Vector2 = get_middle()
	equipment_radius = min(middle_of_screen.x, middle_of_screen.y)-120.0
	var index = 0
	for x in equipment_scenes:
		var angle : float = TAU * index / equipment_scenes.size()
		var desired_location := middle_of_screen + (Vector2.UP * equipment_radius).rotated(angle_offset + angle)
		x.position = Kinematics.damp(x.position, desired_location, 7.0, delta)
		index+=1
	angle_offset += delta * 0.02
	

func spawn_character(character_info : CharacterInfo) -> void:
	equipment_scenes = []
	all_equipment = []
	spawn_all_equipment(character_info)

func spawn_all_equipment(character_info : CharacterInfo) -> void:
	var index : int = 0
	for i in character_info.equipment_list:
		var new_equipment = spawn_equipment(i)
		new_equipment.id = index
		index += 1

func spawn_equipment(equipment : Equipment) -> Node2D:
	var new_equipment = equipment_card.instantiate()
	equipment_scenes.push_back(new_equipment)
	all_equipment.push_back(new_equipment)
	add_child(new_equipment)
	new_equipment.assign_info(equipment)
	return new_equipment
	

func get_middle() -> Vector2:
	return Global.game_size * 0.5

func remove_equipment(eq):
	#angle_offset = randf_range(0.0, TAU)
	var ind = equipment_scenes.find(eq)
	equipment_scenes.remove_at(ind)

func draw_interactable_card():
	var new_monster_card = monster_card.instantiate()
	add_child(new_monster_card)
	#new_monster_card.position = Vector2(Global.game_size.x-50.0, -100.0)

func spawn_replicated_monster_card():
	var new_monster_card_replica = monster_card_replica.instantiate()
	add_child(new_monster_card_replica)
	has_replicated_monster_card = true
	current_replicated_monster_card = new_monster_card_replica

func force_fade_replicated_monster_card(target):
	has_replicated_monster_card = false
	current_replicated_monster_card.force_fade(target)
	current_replicated_monster_card = null
