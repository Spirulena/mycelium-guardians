extends Button
class_name UnitButton

var assigned_unit: Unit

func assign_unit(unit: Unit):
	assigned_unit = unit
	text = unit.name

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	if assigned_unit:
		UnitController.instance.set_selected_unit(assigned_unit)
