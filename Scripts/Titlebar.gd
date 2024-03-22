extends PanelContainer

var following = false
var dragging_start_pos : Vector2
@export var resize_controls : Node

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			following = !following
			dragging_start_pos = get_local_mouse_position()
		if event.double_click:
			_on_windowed_button_pressed()


func _process(_delta):
	if following:
		var mouse_difference = get_global_mouse_position() - dragging_start_pos
		get_window().position += mouse_difference as Vector2i


func _on_exit_button_pressed():
	get_tree().quit()


func _on_windowed_button_pressed():
	# Toggle windowed mode
	if get_window().mode == Window.MODE_WINDOWED:
		get_window().mode = Window.MODE_FULLSCREEN
		resize_controls.hide()
	else:
		get_window().mode = Window.MODE_WINDOWED
		resize_controls.show()


func _on_minimize_button_pressed():
	get_window().mode = Window.MODE_MINIMIZED
