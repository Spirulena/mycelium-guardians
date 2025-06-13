extends Control

@export var parent: Node
@onready var back = %Back
@onready var reset_hints: Button = $VisibilityContainer/ResetHints

func _ready():
	back.pressed.connect(back_pressed)
	reset_hints.pressed.connect(on_reset_hints_pressed)

# NOTE: remove ?
func on_reset_hints_pressed():
	# TODO: separate hints and tutorial prefs-
	LevelController.get_level_controller().reset_user_preferences()

func back_pressed():
	var change = {
		'type': 'ShowScreen',
		'screen': 'HelpMenu',
		'prev': true,
		'curr': false,
	}
	_view_changed(change)

func _view_changed(change):
	parent.main_view_changed.emit(change)
