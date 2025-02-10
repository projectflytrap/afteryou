extends Serializable
class_name PlayerInfo

var username : String = "NO_NAME"
var player_number : int = 0
var ready : bool = false
var disconnected : bool = false

func update(pri : PlayerRequestInfo):
	username = pri.username
	print("Updated username : ", username)

func is_ready() -> bool:
	return ready && !disconnected
