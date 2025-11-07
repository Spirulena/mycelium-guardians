extends Unit
class_name PlayerUnit

var is_selected: bool = false
@export var click_collider: CollisionShape2D

func _ready():
	input_pickable = true
	connect("input_event", Callable(self, "_on_unit_input"))

func _on_unit_input(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if team == Team.Player:
			
			if UnitController.instance.current_selected_unit == self:
				UnitController.instance.clear_selection()
			else:
				UnitController.instance.set_selected_unit(self)

func force_select():
	is_selected = true
	TilemapGrid.instance.show_unit_selection(self)

func clear_select():
	is_selected = false
	TilemapGrid.instance.clear_unit_selection(self)

func _toggle_selection():
	print("Unit_Player: Toggle selection:", name, "->", !is_selected)
	_set_selected(!is_selected)

func _set_selected(selected: bool):
	is_selected = selected
	print("Unit_Player: Set selected:", name, "=", selected)
	
	if is_selected:
		UnitController.instance.set_selected_unit(self)
		TilemapGrid.instance.show_unit_selection(self)
	else:
		TilemapGrid.instance.clear_unit_selection(self)
