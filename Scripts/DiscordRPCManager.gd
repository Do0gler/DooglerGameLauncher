extends Node

var launched_has_rpc := false
var rpc_suspended := false
var rich_presence_enabled := true:
	set(value):
		rich_presence_enabled = value
		if value:
			resume_rpc()
		else:
			suspend_rpc()

func _ready():
	if rich_presence_enabled:
		DiscordRPC.app_id = 1266920850339139664
		enter_library()

func suspend_rpc():
	rpc_suspended = true
	DiscordRPC.clear()
	DiscordRPC.refresh()

func resume_rpc():
	rpc_suspended = false
	DiscordRPC.unclear()
	if DiscordRPC.app_id == 0:
		DiscordRPC.app_id = 1266920850339139664
		enter_library()
	DiscordRPC.refresh()

func started_playing_game(game : Game_Data):
	if rich_presence_enabled:
		DiscordRPC.details = "Playing " + game.game_name
		DiscordRPC.large_image = game.api_icon_name
		DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
		DiscordRPC.refresh()

func enter_library():
	if rich_presence_enabled:
		DiscordRPC.details = "Browsing Library"
		DiscordRPC.large_image = "logo"
		DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
		DiscordRPC.refresh()
