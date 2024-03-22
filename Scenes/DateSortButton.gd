extends Button

var times_pressed := 0
@onready var game_manager = get_tree().root.get_child(1)
func _on_pressed():
	if times_pressed <= 2:
		game_manager.sort_by_date(times_pressed <= 1, times_pressed)
	if times_pressed >= 3:
		game_manager.sort_alphabet()
		times_pressed = 0
	times_pressed += 1
