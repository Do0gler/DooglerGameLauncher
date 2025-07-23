extends PanelContainer
class_name GamePanel

var game_data: Game_Data

func update_display():
	$MarginContainer/HBoxContainer/TextureRect.texture = game_data.icon
	$MarginContainer/HBoxContainer/Label.text = game_data.game_name
	$MarginContainer/HBoxContainer/UpdateIndicator.visible = game_data.is_outdated

func set_current_game():
	var manager: Manager = get_tree().root.get_node("Manager")
	manager.set_current_game(self)
