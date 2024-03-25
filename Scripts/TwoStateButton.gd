extends Button

@export var on_icon : Texture2D = preload("res://UIArt/RegularOrderIcon.png")
@export var off_icon : Texture2D = preload("res://UIArt/ReverseOrderIcon.png")
@export var state := false

func _ready():
	display()

func display():
	if state:
		icon = on_icon
	else:
		icon = off_icon

func toggle_state():
	state = !state
	display()

func turn_off():
	icon = off_icon
	state = false
