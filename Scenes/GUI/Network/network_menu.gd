@tool
class_name NetworkMenu extends Control

@export var nm_actions: Array[NetworkMenuAction]
@export var template: PackedScene
@export var grid: GridContainer
@export var parent: GUIController

func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
	for action in nm_actions:
		# setup parent
		action.parent = self
		var ui_element: NetworkMenuUIElement = template.instantiate()
		grid.add_child(ui_element)
		ui_element.setup(action)

## Being called by NetworkMenuAction
func handle_press(action: NetworkMenuAction):
	print_debug("Handle press, in NetworkMenu: %s" % [action.name])
	if action.name == 'thicken':
		parent.set_current_action_mode(GUIController.Actions.Thicken)
	# emit view change.
	# a lot of piping for something that should just be
	# emit to button_events.emit(button_id) ?
