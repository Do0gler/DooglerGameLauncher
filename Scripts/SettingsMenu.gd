extends PopupMenu


func _on_id_pressed(id: int) -> void:
	match id:
		1: # Auto-Updating
			toggle_item_checked(id)
			Updater.auto_check_updates = is_item_checked(id)
		2: # Discord RPC
			toggle_item_checked(id)
			DiscordRpcManager.rich_presence_enabled = false
	SettingsManager.save_settings()

func settings_opened():
	show()
