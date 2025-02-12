extends Serializable

class_name MainPhaseDecision

enum intents {bail, remove_equipment, add_monster, none}

var intent = intents.bail

var equipment_id : int = -1
