extends Resource

class_name Equipment

@export var art : Texture2D
@export var name : String
enum types {weapon, passive, follower, ability}
@export var type : types
var innate : bool = false
@export_multiline var effect_text : String
