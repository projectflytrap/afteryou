extends Line2D

var base : Node2D
var targeting : bool = false
var target : Node2D = null
var active : bool = true
const ARC_POINTS : int = 30
@onready var arrowhead = $Arrowhead

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	active = targeting
	if !base:
		active = false
	visible = active
	if !visible:
		modulate.a = 0.0
		return
	else:
		modulate.a = Kinematics.dampf(modulate.a, 1.0, 10.0, delta)
	poll_valid_targets()
	var target_position : Vector2 = Vector2.ZERO
	if target == null:
		target_position = get_global_mouse_position()
	else:
		target_position = target.position
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
