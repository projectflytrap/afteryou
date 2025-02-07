extends Serializable
class_name PlayerInfo

var username : String = "NO_NAME"
var player_number : int = 0


func update(pri : PlayerRequestInfo):
	username = pri.username
	print("Updated username : ", username)
