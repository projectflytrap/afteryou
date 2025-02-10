extends Line2D

var base : Node2D
var targeting : bool = false
var target : Node2D = null
var active : bool = true
var visualized_target := -1
const ARC_POINTS : int = 30
@onready var arrowhead = $Arrowhead
@export_node_path() var synchronizer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Gameplay.game_phase == Gameplay.game_phases.main:
		main_phase_targeting(delta)
	

func main_phase_targeting(delta: float):
	if Gameplay.am_i_current_player():
		active = targeting
		if !base || !is_instance_valid(base):
			active = false
		if targeting:
			poll_valid_targets()
			var target_position : Vector2 = Vector2.ZERO
			if target == null:
				target_position = get_global_mouse_position()
			else:
				target_position = target.position
			draw_target(target_position, delta)
	else:
		var current_target_index : int = get_parent().get_node("Synchronizer").current_target_index
		if  current_target_index != -1:
			active = true
			#visualized_target = get_parent().all_equipment[current_target_index] 
			visualized_target = current_target_index
		if visualized_target == -1:
			active = false
		if active:
			draw_target(get_parent().all_equipment[current_target_index].global_position, delta)
	if !active:
		modulate.a = Kinematics.dampf(modulate.a, 0.0, 16.0, delta)
	else:
		modulate.a = Kinematics.dampf(modulate.a, 1.0, 10.0, delta)
	visible = modulate.a >= 0.05

func draw_target(target_position : Vector2, delta : float):
	var new_points = _get_points(base.position, target_position)
	if points.size()-1 != ARC_POINTS:
		points = new_points
	else:
		for i in range(ARC_POINTS + 1):
			points[i] = Kinematics.damp(points[i], new_points[i], 12.0 + -3.0 * float(target != null), delta)
	arrowhead.position = lerp(points[-2], points[-1], 0.5)
	arrowhead.rotation = points[-2].angle_to_point(points[-1])

func _get_points(start_position : Vector2, end_position : Vector2) -> Array:
	var p := []
	var distance := end_position - start_position
	
	for i in range(ARC_POINTS):
		var t := (1.0/ARC_POINTS) * i
		var x := start_position.x + distance.x * i / float(ARC_POINTS)
		var y := start_position.y + ease(t, -1.6) * distance.y
		p.append(Vector2(x,y))
	p.append(end_position)
	return p

func poll_valid_targets():
	target = null
	get_tree().call_group("Targetable", "check_valid_target")

func remove_selection():
	targeting = false
	target = null

func update_color_to_current_player():
	modulate = Values.get_color_main(Gameplay.current_player)
