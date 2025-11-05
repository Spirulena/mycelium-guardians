extends Unit
class_name PlayerUnit

@onready var selection_visual = $"../UnitSelectionHighlight"

func toggle_selection_visual (toggle : bool):
	selection_visual.visable = toggle

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_move_to(get_global_mouse_position())
