extends Button

@export var parent: Node

func _ready():
	pressed.connect(resume_pressed)

func resume_pressed():
	var change = {
		'type': 'PauseGame',
		'screen': 'PauseMenu',
		'prev': false,
		'curr': true,
	}
	parent.view_changed.emit(change)
