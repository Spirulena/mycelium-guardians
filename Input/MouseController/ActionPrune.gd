extends ActionHandler
class_name ActionPrune

func _init(parent: MouseController):
	super(parent, GUIController.Actions.Prune)

func handle_press(coords: Vector2i):
	is_executing = true
	handle_move(coords)

func handle_move(coords: Vector2i):
	parent.set_highlight(coords, LevelController.get_level_controller().can_prune_at_coords(coords))

	if is_executing:
		LevelController.get_level_controller().prune_at_coords(coords)

# Called when the node enters the scene tree for the first time.
func handle_release(coords: Vector2i):
	is_executing = false
