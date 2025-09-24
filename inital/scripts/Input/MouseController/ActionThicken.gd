extends ActionHandler
class_name ActionThicken

func _init(parent: MouseController):
	super(parent, GUIController.Actions.Thicken)

func handle_press(coords: Vector2i):
	is_executing = true
	# Maybe not ?
	# Just press, and ask for confirmation ?
	# Handle move on press is like paint
	handle_move(coords)

func handle_move(coords: Vector2i):
	parent.set_highlight(coords, true)

	if is_executing:
		# Emit request
		parent.view_changed({
			'type': GUIController.Actions.Thicken,
			'state': 'request',
			'coords': coords,
		})

# Called when the node enters the scene tree for the first time.
func handle_release(coords: Vector2i):
	is_executing = false
