extends Node
class_name UIActionSelection

var _selection_buttons: Array[ActionSelectionButton]

func register_selection_button(button: ActionSelectionButton):
	_selection_buttons.push_back(button)

func set_selected(action: GameplayPresenter.Action):
	for button in _selection_buttons:
		button.selected_action(action)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
