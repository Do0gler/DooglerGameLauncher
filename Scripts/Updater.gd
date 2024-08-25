extends Node

var ver_ref_path := "http://dl.dropboxusercontent.com/scl/fi/e9g5x5oxw1qsusqouq9ev/game_versions.txt?rlkey=uf408yr47g8ia2uyq4glsf70c&st=j27ibb9n&dl=0"
var auto_check_updates := true
@onready var loading_screen = get_tree().root.get_node("Manager/LoadingScreen")

func check_for_updates():
	# Download Version Refrence file
	loading_screen.show()
	var http := HTTPRequest.new()
	add_child(http)
	var download_file_path = "user://game_versions.txt"
	var new_ver_ref_file = FileAccess.open(download_file_path, FileAccess.WRITE_READ)
	http.download_file = download_file_path
	http.request(ver_ref_path)
	await http.request_completed
	var ver_dict : Dictionary = JSON.parse_string(new_ver_ref_file.get_as_text())
	# Check if downloaded games are outdated
	var manager := get_tree().root.get_node("Manager") as Manager
	for game in manager.default_game_order:
		var game_data = game as Game_Data
		game_data.is_outdated = true if game_data.version_number != ver_dict[game_data.game_name] else false
	loading_screen.hide()
	return
