extends ActionHandler
class_name ActionSelect

var _press_coords: Vector2i
var _is_gesture: bool

func _init(parent: MouseController):
	super(parent, GUIController.Actions.Select)
	_is_gesture = false

func reset():
	super.reset()
	_is_gesture = false

func handle_press(coords: Vector2i):
	_press_coords = coords
	#_is_gesture = LevelController.get_level_controller().is_mycelium_at(coords)
	_is_gesture = LevelController.get_level_controller().is_mycelium_any_at(coords)

func handle_move(coords: Vector2i):
	if _is_gesture:
		if _press_coords != coords:
			# below needs to pass the coords
			parent.swap_action(GUIController.Actions.Explore, _press_coords, coords)
	else:
		parent.set_highlight(coords, true)

func handle_release(coords: Vector2i):
	_is_gesture = false
	var tile = LevelController.get_level_controller().get_tile_at(coords)
	parent.set_selected({
		'coords': coords,
		'tile': tile,
	})
