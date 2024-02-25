extends Control

var mouse_offset
var following = false
var window_position
var window_size
var main_window
enum ResizeDir {Horizontal, Vertical, Diagonal}
enum Corners {None, Top_Right, Top_Left, Bottom_Left}
@export var primary_side = false
@export var resize_direction: ResizeDir
@export var diagonal_corner: Corners


func _ready():
	main_window = get_window()
	var min_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var min_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	main_window.min_size = Vector2(min_width,min_height)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			mouse_offset = get_local_mouse_position()
			window_position = main_window.position
			window_size = main_window.size
			following = !following

func _process(_delta):
	if following:
		match resize_direction:
			ResizeDir.Vertical:
				if primary_side:
					resize_y_primary()
				else:
					main_window.size.y = get_global_mouse_position().y - mouse_offset.y
			ResizeDir.Horizontal:
				if primary_side:
					resize_x_primary()
				else:
					main_window.size.x = get_global_mouse_position().x - mouse_offset.x
			ResizeDir.Diagonal:
				if primary_side:
					match diagonal_corner:
						Corners.Top_Right:
							resize_y_primary()
							main_window.size.x = get_global_mouse_position().x - mouse_offset.x
						Corners.Bottom_Left:
							resize_x_primary()
							main_window.size.y = get_global_mouse_position().y - mouse_offset.y
						Corners.Top_Left:
							resize_x_primary()
							resize_y_primary()
				else:
					main_window.size = get_global_mouse_position() - mouse_offset

func resize_x_primary():
	var move_calc = main_window.position as Vector2 + get_global_mouse_position() - mouse_offset
	var will_grow_left = move_calc.x < main_window.position.x
	if main_window.size.x > main_window.min_size.x || will_grow_left:
		main_window.position.x = move_calc.x
	main_window.size.x = window_size.x + (window_position.x - main_window.position.x)

func resize_y_primary():
	var move_calc = main_window.position as Vector2 + get_global_mouse_position() - mouse_offset
	var will_grow_up = move_calc.y < main_window.position.y
	if main_window.size.y > main_window.min_size.y || will_grow_up:
		main_window.position.y = move_calc.y
	main_window.size.y = window_size.y + (window_position.y - main_window.position.y)
