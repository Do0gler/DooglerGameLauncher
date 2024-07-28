extends Node

var launched_has_rpc := false

func _ready():
	DiscordRPC.app_id = 1266920850339139664
	enter_library()

func started_playing_game(game : Game_Data):
	DiscordRPC.details = "Playing " + game.game_name
	DiscordRPC.large_image = game.api_icon_name
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()

func enter_library():
	DiscordRPC.details = "Browsing Library"
	DiscordRPC.large_image = "logo"
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
