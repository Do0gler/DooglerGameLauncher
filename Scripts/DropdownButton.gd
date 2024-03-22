extends Button

@export var order_regular_icon : Texture2D = preload("res://UIArt/RegularOrderIcon.png")
@export var order_reversed_icon : Texture2D = preload("res://UIArt/ReverseOrderIcon.png")
@export var order_disabled_icon : Texture2D = preload("res://UIArt/DisabledOrderIcon.png")

func _ready():
	set_sort_disabled()

func toggle_sort_order(toggled : bool):
	if toggled:
		icon = order_reversed_icon
	else:
		icon = order_regular_icon

func set_sort_disabled():
	icon = order_disabled_icon
