extends Button

@export var on_icon: Texture2D = preload("res://UIArt/RegularOrderIcon.png")
@export var off_icon: Texture2D = preload("res://UIArt/ReverseOrderIcon.png")
@export var state := false

func _ready() -> void:
	pressed.connect(toggle_state)
	display()

func display() -> void:
	if state:
		icon = on_icon
	else:
		icon = off_icon

func toggle_state() -> void:
	state = !state
	display()

func turn_off() -> void:
	icon = off_icon
	state = false
