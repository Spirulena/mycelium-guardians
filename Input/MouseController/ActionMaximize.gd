extends ActionHandler
class_name ActionMaximize

func _init(parent: MouseController):
	super(parent, GUIController.Actions.Maximize)

func handle_press(coords: Vector2i):
	is_executing = true
	handle_move(coords)

func handle_move(coords: Vector2i):
	parent.set_highlight(coords, true)

	if is_executing:
		LevelController.get_level_controller().harvest_from_coords(coords)

# Called when the node enters the scene tree for the first time.
func handle_release(coords: Vector2i):
	is_executing = false
