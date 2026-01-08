extends Node
class_name UIActionSelection

var _selection_buttons: Array[ActionSelectionButton]
var _current_action: GameplayPresenter.Action

signal selection_changed(prev, curr)

func register_selection_button(button: ActionSelectionButton):
	_selection_buttons.push_back(button)

func set_selected(action: GameplayPresenter.Action):
	var prev_action = _current_action
	_current_action = action

	for button in _selection_buttons:
		button.selected_action(_current_action)

	selection_changed.emit(prev_action, _current_action)

func _ready():
	set_selected(GameplayPresenter.Action.SELECT)

func _process(delta):
	pass

func _input(event: InputEvent):
	if event.is_action_released("mycelium_grow"):
		set_selected(GameplayPresenter.Action.GROW_MYCELIUM)
