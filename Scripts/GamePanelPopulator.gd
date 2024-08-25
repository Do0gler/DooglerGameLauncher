extends PanelContainer

var game_data : Game_Data

func update_display():
	$MarginContainer/HBoxContainer/TextureRect.texture = game_data.icon
	$MarginContainer/HBoxContainer/Label.text = game_data.game_name
	$MarginContainer/HBoxContainer/UpdateIndicator.visible = game_data.is_outdated

func set_current_game():
	get_tree().root.get_node("Manager").set_current_game(game_data)
