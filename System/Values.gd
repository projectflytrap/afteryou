class_name Values

const equipment_color_weapon : Color = Color(0.996, 0, 0.159)
const equipment_color_passive : Color = Color(0.267, 0.436, 1)
const equipment_color_follower : Color = Color(0, 0.637, 0.387)
const equipment_color_ability : Color = Color(0.955, 0.797, 0)


const player_color_main = [
	Color(0.964, 0.689, 0),
	Color(0.063, 0.745, 1),
	Color(0.325, 0.98, 0.196),
	Color(1, 0.063, 0.426),
	]

const player_color_main_default = Color.LIGHT_SLATE_GRAY

const player_color_light = [
	Color(1, 0.872, 0.662),
	Color(0.596, 0.858, 1),
	Color(0.693, 0.998, 0.643),
	Color(1, 0.648, 0.706),
	] 

const player_color_light_default = Color.LIGHT_GRAY

static func get_color_main(player_number : int) -> Color:
	if player_number >= player_color_main.size() || player_number < 0:
		return player_color_main_default
	return player_color_main[player_number]

static func get_color_light(player_number : int) -> Color:
	if player_number >= player_color_light.size() || player_number < 0:
		return player_color_light_default
	return player_color_light[player_number]

static func get_equipment_color(type) -> Color:
	match type:
		Equipment.types.weapon:
			return equipment_color_weapon
		Equipment.types.follower:
			return equipment_color_follower
		Equipment.types.passive:
			return equipment_color_passive
		Equipment.types.ability:
			return equipment_color_ability
	return Color.LIGHT_GRAY
