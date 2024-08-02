@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var dict : Dictionary
	var library_folder = DirAccess.open("res://GameLibrary")
	if library_folder:
		library_folder.list_dir_begin()
		var file_name = library_folder.get_next()
		while file_name != "":
			var game_data_path = "res://GameLibrary/" + file_name
			var game_data = (load(game_data_path) as Game_Data)
			dict[game_data.game_name] = game_data.version_number
			file_name = library_folder.get_next()
	var file = FileAccess.open("res://game_versions.txt", FileAccess.WRITE)
	file.store_string(str(dict))
	print("Saved version data file")
