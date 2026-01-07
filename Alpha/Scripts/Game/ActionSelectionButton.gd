extends Button
class_name ActionSelectionButton

@export
var action: GameplayPresenter.Action

var _parent: UIActionSelection

func selected_action(selected_action: GameplayPresenter.Action):
	if selected_action == action:
		text = "selected"
	else:
		text = "deselected"

# Called when the node enters the scene tree for the first time.
func _ready():
	_parent = get_parent() as UIActionSelection
	_parent.register_selection_button(self)
	pressed.connect(_on_button_clicked)

func _on_button_clicked():
	_parent.set_selected(action)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
