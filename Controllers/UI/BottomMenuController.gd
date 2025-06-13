class_name OldButtomButtons extends HBoxContainer
## Buttom menu buttons handler

@export var root_gui: GUIController

func _init():
	pass

func _ready():
	pass

## React to GUIController.action_changed - To add visual effect
func register_button(button: OldButtomButtons_Button):
	root_gui.action_changed.connect(button.action_changed)

## React to pressed button, Could be handled in component rather then fixed here
## TODO: move to switch statement
func button_pressed(button_type: String):
	# Switch here or
	root_gui.set_current_action_mode(button_type)
