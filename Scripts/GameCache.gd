extends Resource
class_name GameCache

@export var game_size_mb : float
@export var game_version : String

func _init(size = 0, version = "1.0"):
	game_size_mb = size
	game_version = version
