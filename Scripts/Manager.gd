extends Control

@export var game_panel : PackedScene
@export var screenshot_panel : PackedScene
var game_folder_name : String = "DooglerGamesLibrary"
var selected_game : Game_Data
var current_game_pid = 0
var game_launched = false
var can_switch_games = true
var launched_game_is_exe = false
var downloading = false
var http : HTTPRequest
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

func _ready():
	var dir = DirAccess.open("user://")
	if(!dir.dir_exists(game_folder_name)):
		dir.make_dir(game_folder_name)
		print("Created Library folder")
	display_games()

func _process(_delta):
	if game_launched:
		if !OS.is_process_running(current_game_pid):
			game_launched = false
			can_switch_games = true
			stop_button.hide()
	if downloading:
		var body_size = selected_game.file_size_mb * 1000000
		var downloaded_bytes = http.get_downloaded_bytes()
		var percent = int(downloaded_bytes * 100 / body_size)
		progress_bar.value = percent

func display_games():
	var i = 0
	var dir = DirAccess.open("res://GameLibrary")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var new_game_panel = game_panel.instantiate()
				var file = load("res://GameLibrary/" + file_name.replace(".remap",""))
				games_list.add_child(new_game_panel)
				new_game_panel.game_data = file
				if i == 0:
					selected_game = file
					display_selected_game()
				new_game_panel.update_display()
			file_name = dir.get_next()
			i += 1
	else:
		print("An error occurred when trying to access the path.") 

func set_current_game(game_data : Game_Data):
	if can_switch_games:
		selected_game = game_data
		display_selected_game()

func install_selected_game():
	if selected_game != null:
		http = HTTPRequest.new()
		add_child(http)
		var download_file_path = "user://" + game_folder_name + "/" + selected_game.file_name
		var new_game_file = FileAccess.open(download_file_path, FileAccess.WRITE)
		http.download_file = download_file_path
		can_switch_games = false
		install_button.disabled = true
		http.request(selected_game.download_path)
		downloading = true
		progress_bar.show()
		await http.request_completed
		print("Finished Download")
		progress_bar.hide()
		install_button.disabled = false
		downloading = false
		can_switch_games = true
		install_button.hide()
		uninstall_button.show()
		new_game_file.close()

func show_uninstall_confirm():
	$ConfirmationDialog.show()

func uninstall_current_game():
	# Uninstall Game
	var current_game_path = "user://" + game_folder_name + "/" + selected_game.file_name
	DirAccess.remove_absolute(ProjectSettings.globalize_path(current_game_path))
	display_selected_game()

func launch_selected_game():
	if selected_game != null:
		var current_game_path = "user://" + game_folder_name + "/" + selected_game.file_name
		var global_path = ProjectSettings.globalize_path(current_game_path)
		if(selected_game.file_name.get_extension() == "exe"):
			if current_game_pid == 0:
				current_game_pid = OS.create_process(global_path,[])
				if current_game_pid == -1:
					print("could not start game")
				else:
					stop_button.show()
					game_launched = true
					can_switch_games = false
					launched_game_is_exe = true
			else:
				OS.kill(current_game_pid)
				current_game_pid = 0
		else:
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
	display_description.text = "File Size: " + str(selected_game.file_size_mb) + " MB\n"\
	 + selected_game.description
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
	var dir = DirAccess.open("user://" + game_folder_name)
	if dir.file_exists(selected_game.file_name):
		install_button.hide()
		uninstall_button.show()
	else:
		install_button.show()
		uninstall_button.hide()

func _on_screenshot_popup_open(screenshot_index):
	$ScreenshotPopup/VBoxContainer/TextureRect.texture = selected_game.screenshots[screenshot_index]
	$ScreenshotPopup.show()

func _on_screenshot_popup_close_requested():
	$ScreenshotPopup.hide()
