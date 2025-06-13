extends Button

@export var parent: Node

func _ready():
	pressed.connect(resume_pressed)

func resume_pressed():
	var change = {
		'type': 'ResumeGame',
		'screen': 'PauseMenu',
		'prev': false,
		'curr': true,
	}
	parent._view_changed(change)
