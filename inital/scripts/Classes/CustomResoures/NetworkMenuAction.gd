class_name NetworkMenuAction extends Resource

@export var icon: Texture2D
@export var icon_size: Vector2 = Vector2.ONE
@export var name: String = ""
@export var comment: String = ""
var parent: NetworkMenu

## Handle Press in Parent ::NetworkMenu::
func handle_press():
	parent.handle_press(self)
	print_debug("Handle press from NetworkMenuAction: %s" % [name])
	# Propagate to parrent ?
	# _parent.handle_press(self)
	# Name -> dictionary_template
	# Name -> Enum ?
	# need to have _view. to emit change

	# Used to emit change, action, request
	# Then router will do whatever with it, as it please
# Not the level Controller it should just have functions and stuff
# Some router, default, then components

#

# ready and connect ?
# have a button there ? or just data and logic

# Other actions for Myceliu Network
# - [ ]
