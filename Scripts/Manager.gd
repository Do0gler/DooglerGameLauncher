extends Control

@export var game_panel : PackedScene
@export var screenshot_panel : PackedScene
@export var expandable_list : PackedScene
@export var tag_scene : PackedScene
var library_folder_name : String = "DooglerGamesLibrary"
var selected_game : Game_Data
var current_game_pid = 0
var game_launched = false
var default_game_order : Array
var all_games : Dictionary
var can_switch_games = true
var launched_game_is_exe = false
var downloading = false
var http : HTTPRequest
var sorting_method : Callable = sort_default
var sorting_method_reversed := false
@export var games_list : Node
@export var display_description : Node
@export var display_icon : Node
@export var display_bg : Node
@export var display_name : Node
@export var install_button : Node
@export var stop_button : Node
@export var progress_bar : Node
@export var uninstall_button : Node
@export var screenshot_container : Node
@export var tag_container : Node

func _ready():
	default_game_order = GameOrganizer.get_default_order()
	all_games = GameOrganizer.categorize_by_default(default_game_order)
	var dir = DirAccess.open("user://")
	if(!dir.dir_exists(library_folder_name)):
		dir.make_dir(library_folder_name)
		print("Created Library folder")
	display_games()

func _process(_delta):
	if game_launched:
		if !OS.is_process_running(current_game_pid):
			game_launched = false
			can_switch_games = true
			stop_button.hide()
			DiscordRpcManager.enter_library()
	if downloading:
		var body_size = selected_game.file_size_mb * 1000000
		var downloaded_bytes = http.get_downloaded_bytes()
		var percent = int(downloaded_bytes * 100 / body_size)
		progress_bar.value = percent

func display_games():
	var games_in_list = games_list.get_children()
	if games_in_list.size() > 0:
		for game in games_in_list:
			game.queue_free()
	var i = 0
	for key in all_games:
		var new_list = expandable_list.instantiate()
		var new_list_script = new_list.get_child(0)
		new_list_script.list_name = key
		games_list.add_child(new_list)
		for game in all_games[key]:
			var new_game_panel = game_panel.instantiate()
			new_list_script.add_item(new_game_panel)
			new_game_panel.game_data = game
			if i == 0:
				selected_game = game
				display_selected_game()
			i += 1
			new_game_panel.update_display()
		new_list_script.update_visuals()

func set_current_game(game_data : Game_Data):
	if can_switch_games:
		selected_game = game_data
		display_selected_game()

func install_selected_game():
	if selected_game != null:
		http = HTTPRequest.new()
		add_child(http)
		# Create game folder if it doesnt exist
		var game_folder_name = selected_game.file_name.get_basename()
		var dir = DirAccess.open("user://" + library_folder_name)
		if(!dir.dir_exists(game_folder_name)):
			dir.make_dir(game_folder_name)
		var download_file_path = "user://" + library_folder_name +\
		 "/" + game_folder_name + "/"+ selected_game.file_name
		# Create file to write download to
		var new_game_file = FileAccess.open(download_file_path, FileAccess.WRITE)
		# Start download and related functions
		http.download_file = download_file_path
		can_switch_games = false
		install_button.disabled = true
		http.request(selected_game.download_path)
		downloading = true
		progress_bar.show()
		# Wait for download to finish and stop related functions
		await http.request_completed
		# Extract file contents if is a zip
		if(selected_game.file_name.get_extension() == "zip"):
			extract_zip_file(download_file_path, download_file_path.get_base_dir())
		print("Finished Download")
		progress_bar.hide()
		install_button.disabled = false
		downloading = false
		can_switch_games = true
		install_button.hide()
		uninstall_button.show()
		new_game_file.close()
		display_selected_game()

func show_uninstall_confirm():
	$ConfirmationDialog.show()

func uninstall_current_game():
	# Uninstall Game
	var current_game_path = "user://" + library_folder_name +\
		 "/" + selected_game.file_name.get_basename()
	recursive_delete_game(current_game_path)
	display_selected_game()

func launch_selected_game():
	if selected_game != null:
		var current_game_path = "user://" + library_folder_name +\
		 "/" + selected_game.file_name.get_basename() + "/"+ selected_game.game_file_name
		var global_path = ProjectSettings.globalize_path(current_game_path)
		if(selected_game.game_file_name.get_extension() == "exe"):
			if current_game_pid == 0:
				current_game_pid = OS.create_process(global_path,[])
				if current_game_pid == -1:
					print("could not start game")
					DiscordRpcManager.enter_library()
				else:
					DiscordRpcManager.started_playing_game(selected_game)
					stop_button.show()
					game_launched = true
					can_switch_games = false
					launched_game_is_exe = true
			else:
				OS.kill(current_game_pid)
				current_game_pid = 0
				DiscordRpcManager.enter_library()
		else:
			current_game_pid = 0
			var error = OS.execute("CMD.exe",["/C", '"' + global_path + '"'])
			if error == -1:
				print("could not start game")
			else:
				game_launched = true
				launched_game_is_exe = false

func display_selected_game():
	# Destroy previous screenshots
	for screenshot in screenshot_container.get_child(0).get_children():
		screenshot.queue_free()
	# Set new game info
	display_name.text = selected_game.game_name
	display_icon.texture = selected_game.icon
	display_bg.texture = selected_game.background
	# Show new screenshots
	screenshot_container.visible = !selected_game.screenshots.size() == 0
	var i = 0
	for image in selected_game.screenshots:
		var screenshot = screenshot_panel.instantiate()
		screenshot.texture = image
		screenshot_container.get_child(0).add_child(screenshot)
		screenshot.get_child(0).pressed.connect(_on_screenshot_popup_open.bind(i))
		i += 1
	# Show correct buttons for if file is installed or not
	var game_folder_path = "user://" + library_folder_name +\
	 "/" + selected_game.file_name.get_basename()
	var dir = DirAccess.open(game_folder_path)
	var game_size : String
	if dir:
		if dir.file_exists(selected_game.game_file_name):
			# Load game cached data if exists else calculate size and create cache
			var cache_name = selected_game.file_name.get_basename() + "Cache.tres"
			var cache_path = game_folder_path + "/" + cache_name
			if dir.file_exists(cache_name):
				var res := ResourceLoader.load(cache_path)
				game_size = str(res.game_size_mb)
			else:
				var size_mb := snappedf(recursive_size_game(game_folder_path) / 1000000.0, 0.01)
				game_size = str(size_mb)
				var cache := GameCache.new()
				cache.game_size_mb = size_mb
				cache.resource_name = cache_name
				ResourceSaver.save(cache, cache_path)
			#Show buttons
			install_button.hide()
			uninstall_button.show()
	else:
		game_size = str(selected_game.file_size_mb)
		install_button.show()
		uninstall_button.hide()
	var format = "File Size: %s MB\nDate Created: %s\n%s"
	display_description.text = format % [game_size, selected_game.creation_date, selected_game.description]
	# Remove old tags and add new ones
	for child in tag_container.get_children():
		child.queue_free()
	for tag in selected_game.tags:
		var new_tag = tag_scene.instantiate()
		tag_container.add_child(new_tag)
		new_tag.update_display(tag)

func _on_screenshot_popup_open(screenshot_index):
	var screenshot_tex = $ScreenshotPopup/VBoxContainer/TextureRect
	screenshot_tex.texture = selected_game.screenshots[screenshot_index]
	$ScreenshotPopup.show()

func _on_screenshot_popup_close_requested():
	$ScreenshotPopup.hide()

func extract_zip_file(file_path : String, extract_to_path : String):
	var dir := DirAccess.open(extract_to_path)
	var reader := ZIPReader.new()
	var err := reader.open(file_path)
	if err != OK:
		print("Ecountered an error while extracting")
	for file in reader.get_files():
		if file.ends_with("/"):
			continue
		var file_base_dir = file.get_base_dir()
		if !dir.dir_exists(file_base_dir):
			dir.make_dir_recursive(file_base_dir)
		var new_file_path = extract_to_path.path_join(file)
		var new_file = FileAccess.open(new_file_path, FileAccess.WRITE)
		new_file.store_buffer(reader.read_file(file))
	reader.close()
	# Wait for the zip file to close
	await get_tree().create_timer(0.1).timeout
	dir.remove(selected_game.file_name)
	print("Done Extracting")

func recursive_delete_game(dirPath):
	var dir = DirAccess.open(dirPath)
	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "":
		var filePath = dirPath + "/" + fileName
		if dir.current_is_dir():
			recursive_delete_game(filePath)
		else:
			print("Deleting: " + filePath)
			DirAccess.remove_absolute(filePath)
		fileName = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(dirPath)

func sort_default(reversed := true):
	for category in all_games:
		var sorted_game_list = GameOrganizer.sort_by_name(all_games[category])
		if reversed:
			sorted_game_list.reverse()
		all_games[category] = sorted_game_list
	display_games()
	get_tree().call_group("SortButtons","set_sort_disabled")
	sorting_method = sort_default
	sorting_method_reversed = reversed

func sort_by_date(reversed := true):
	for category in all_games:
		var sorted_game_list = GameOrganizer.sort_by_date(all_games[category])
		if reversed:
			sorted_game_list.reverse()
		all_games[category] = sorted_game_list
	display_games()
	get_tree().call_group("SortButtons","set_sort_disabled")
	sorting_method = sort_by_date
	sorting_method_reversed = reversed

func sort_by_size(reversed := true):
	for category in all_games:
		var sorted_game_list = GameOrganizer.sort_by_size(all_games[category])
		if reversed:
			sorted_game_list.reverse()
		all_games[category] = sorted_game_list
	display_games()
	get_tree().call_group("SortButtons","set_sort_disabled")
	sorting_method = sort_by_date
	sorting_method_reversed = reversed

func group_by_engine():
	all_games = GameOrganizer.categorize_by_engine(default_game_order)
	sorting_method.call(sorting_method_reversed)
	display_games()
	get_tree().call_group("GroupButtons", "turn_off")

func group_by_default():
	all_games = GameOrganizer.categorize_by_default(default_game_order)
	sorting_method.call(sorting_method_reversed)
	display_games()
	get_tree().call_group("GroupButtons", "turn_off")
	
func recursive_size_game(dirPath):
	var size_in_bytes = 0
	var dir = DirAccess.open(dirPath)
	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "":
		var filePath = dirPath + "/" + fileName
		if dir.current_is_dir():
			size_in_bytes += recursive_size_game(filePath)
		else:
			var file = FileAccess.open(filePath, FileAccess.READ)
			size_in_bytes += file.get_length()
		fileName = dir.get_next()
	dir.list_dir_end()
	return size_in_bytes
