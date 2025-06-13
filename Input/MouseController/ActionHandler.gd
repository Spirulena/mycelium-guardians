extends Object
class_name ActionHandler

var parent: MouseController
var is_executing: bool

func _init(parent: MouseController, action: String):
	self.parent = parent
	parent.register_action_handler(action, self)

func reset():
	is_executing = false
