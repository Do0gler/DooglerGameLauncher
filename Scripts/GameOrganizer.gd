extends Node

func sort_by_date(game_list : Array[Game_Data]):
	for i in range(game_list.size() - 1, -1, -1):
		for j in range(1, i + 1, 1):
			if !compare_dates(game_list[j - 1].creation_date, game_list[j].creation_date):
				var temp = game_list[j-1]
				game_list[j-1] = game_list[j]
				game_list[j] = temp
	return game_list

func compare_dates(date1 : String, date2: String): # Check if date one is less than date two
	var date1_array = date1.split("/", false)
	var date2_array = date2.split("/", false)
	var array_order = [2,0,1]
	if date1_array != date2_array:
		for i in array_order:
			if int(date1_array[i]) < int(date2_array[i]):
				return true
			else:
				if int(date1_array[i]) != int(date2_array[i]):
					return false
	else:
		return true

func get_default_order():
	var games_list : Array[Game_Data]
	var dir = DirAccess.open("res://GameLibrary")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var file = load("res://GameLibrary/" + file_name.replace(".remap",""))
				games_list.append(file)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.") 
	return games_list
