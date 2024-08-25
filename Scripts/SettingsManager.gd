extends Node

var settings_file_path = "user://UserSettings.settings"
var manager

func _ready():
	manager = get_tree().root.get_node("Manager") as Manager
	load_settings()

func load_settings():
	var settings_file = FileAccess.open(settings_file_path, FileAccess.READ)
	var settings_dict = JSON.parse_string(settings_file.get_as_text())
	Updater.auto_check_updates = settings_dict["auto_check_updates"]
	DiscordRpcManager.rich_presence_enabled = settings_dict["rich_presence_enabled"]
	(manager.settings_menu as PopupMenu).set_item_checked(1, settings_dict["auto_check_updates"])
	(manager.settings_menu as PopupMenu).set_item_checked(2, settings_dict["rich_presence_enabled"])

func save_settings():
	var settings_dict := {
		"auto_check_updates" :  manager.settings_menu.is_item_checked(1),
		"rich_presence_enabled" : manager.settings_menu.is_item_checked(2)
	}
	var settings_file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	settings_file.store_string(JSON.stringify(settings_dict))
