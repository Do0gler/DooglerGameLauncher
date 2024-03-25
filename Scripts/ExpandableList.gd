extends Button

var disabled_icon = preload("res://UIArt/DisabledOrderIcon.png")
var enabled_icon = preload("res://UIArt/RegularOrderIcon.png")
@onready var items_control := get_parent().get_child(1)
@export var list_name := "Menu"
var number_of_items = 0

func _ready():
	text = list_name

func _on_toggled(toggle):
	icon = disabled_icon if toggle else enabled_icon
	expand_contract(!toggle)

func add_item(item : Node):
	items_control.get_child(0).add_child(item)
	number_of_items += 1

func update_visuals():
	text = list_name + " (" + str(number_of_items) + ")"
	items_control.custom_minimum_size.y = 70 * number_of_items # Temp solution, should be added by the size of the item added

func expand_contract(will_expand):
	var expand_to : int = 0
	if will_expand:
		var items = items_control.get_child(0).get_children()
		if !items.is_empty():
			var last_child = items[items.size() - 1]
			expand_to = last_child.position.y + last_child.size.y
	var tween = create_tween()
	tween.tween_property(items_control, "custom_minimum_size", Vector2(0, expand_to), 0.2)
