extends Node2D
class_name UnitController

static var instance: UnitController
var current_selected_unit: Unit = null

func _ready():
	instance = self

func set_selected_unit(unit: Unit):
	if current_selected_unit and current_selected_unit != unit:
		current_selected_unit.clear_select()
	
	current_selected_unit = unit
	current_selected_unit.force_select()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if current_selected_unit:
				current_selected_unit.try_move_to(get_global_mouse_position())
