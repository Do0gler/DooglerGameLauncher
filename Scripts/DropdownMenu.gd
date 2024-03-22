extends Control

var sub_items : Array[Node]

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			$SubItemsContainer.visible = !$SubItemsContainer.visible
