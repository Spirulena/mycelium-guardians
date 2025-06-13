extends ActionHandler
class_name ActionHealMycelium

func _init(parent: MouseController):
	super(parent, GUIController.Actions.HealMycelium)

func handle_press(coords: Vector2i):
	is_executing = true
	handle_move(coords)

func handle_move(coords: Vector2i):
	parent.set_highlight(coords, true)

	# TODO: just trying - select tile to see do you need to heal it
	var tile = LevelController.get_level_controller().get_tile_at(coords)
	parent.set_selected({
		'coords': coords,
		'tile': tile,
	})

	if is_executing:
		LevelController.get_level_controller().heal_tile(coords)

	# TODO: Ask Boran: should I request heal overlay here on in presenter

func handle_release(coords: Vector2i):
	is_executing = false
