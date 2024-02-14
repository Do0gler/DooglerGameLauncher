extends PanelContainer

var game_data : Game_Data

func update_display():
	$MarginContainer/HBoxContainer/TextureRect.texture = game_data.icon
	$MarginContainer/HBoxContainer/Label.text = game_data.game_name

func set_current_game():
	get_tree().root.get_child(0).set_current_game(game_data)
