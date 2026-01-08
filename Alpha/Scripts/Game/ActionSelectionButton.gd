extends Button
class_name ActionSelectionButton

@export
var action: GameplayPresenter.Action

var _parent: UIActionSelection

func selected_action(selected_action: GameplayPresenter.Action):
	if selected_action == action:
		modulate = Color.GREEN
	else:
		modulate = Color.RED

func _ready():
	_parent = get_parent() as UIActionSelection
	_parent.register_selection_button(self)
	pressed.connect(_on_button_clicked)

func _on_button_clicked():
	_parent.set_selected(action)

func _process(delta):
	pass
