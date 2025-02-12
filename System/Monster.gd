extends Resource

class_name Monster

@export var art : Texture2D
@export var name : String
enum types {none, wog, demon}
@export var type : types
@export_multiline var effect_text : String
