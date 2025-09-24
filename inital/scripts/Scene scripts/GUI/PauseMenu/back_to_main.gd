extends Button

@export var parent: Node

func _ready():
	pressed.connect(_view_changed)

# TODO: can register and then from Pause Manu propegate to GUICOntroller
func _view_changed():
	parent._view_changed({
		'type': 'ShowScreen',
		'screen': 'MainMenu',
		'prev': false,
		'curr': true,
	})
