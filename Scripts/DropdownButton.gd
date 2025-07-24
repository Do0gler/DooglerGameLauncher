extends Button

@export var order_regular_icon: Texture2D = preload("res://UIArt/RegularOrderIcon.png")
@export var order_reversed_icon: Texture2D = preload("res://UIArt/ReverseOrderIcon.png")
@export var order_disabled_icon: Texture2D = preload("res://UIArt/DisabledOrderIcon.png")

func _ready() -> void:
	set_sort_disabled()
	toggled.connect(toggle_sort_order)

func toggle_sort_order(_toggled: bool) -> void:
	if _toggled:
		icon = order_reversed_icon
	else:
		icon = order_regular_icon

func set_sort_disabled() -> void:
	icon = order_disabled_icon
