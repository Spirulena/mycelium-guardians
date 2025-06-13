extends ActionHandler
class_name ActionExplore

var _tiles: Array
var _start: Vector2i
var _end: Vector2i

func _init(parent: MouseController):
	super(parent, GUIController.Actions.Explore)
	_tiles = []

func reset():
	super.reset()
	parent.view_changed({
		'type': GUIController.Actions.Explore,
		'state': 'cancelled',
		'coords': null,
		'tiles': _tiles,
	})
	_tiles = []

func handle_press(coords: Vector2i, next_coords = null):
	is_executing = true

	_start = coords

	parent.view_changed({
		'type': GUIController.Actions.Explore,
		'state': 'started',
		'coords': coords,
		'tiles': _tiles,
	})
	if next_coords != null:
		handle_move(next_coords)
	else:
		handle_move(coords)

func handle_move(coords: Vector2i):
	# TODO: communicate that does not have enough resource,
	# TODO: communicate that not adjecent to other mycelium
	# TODO: could change cursor to indicate, growth over panels
	# also show new acion buttons
	# Eg. connect Tree, or decompose now.
	# Or this can be displayed when mycelium is next to Tree, next to ruin.
	#parent.set_highlight(coords, LevelController.get_level_controller().can_expand_mycelium_at_coords(coords))

	if is_executing:
		# TODO: https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm or
		# https://en.wikipedia.org/wiki/Digital_differential_analyzer_(graphics_algorithm)
		_end = coords
		var x0 = _start.x
		var y0 = _start.y
		var x1 = _end.x
		var y1 = _end.y
		_tiles = []
		_tiles.push_back(Vector2i(x0, y0))
		while x0 != x1 or y0 != y1:
			var dx = x1 - x0
			var dy = y1 - y0
			var move_x = 0
			var move_y = 0
			if dx != 0:
				move_x = dx / abs(dx)  # Move one step in the x direction
			if dy != 0:
				move_y = dy / abs(dy)  # Move one step in the y direction
			if abs(dx) > abs(dy):
				x0 += move_x
			elif abs(dy) > abs(dx):
				y0 += move_y
			else:

				# Handle the case where dx and dy are equal (would move diagonally)
				# Choose to prioritize horizontal or vertical movement based on a condition
				# For simplicity, let's prioritize horizontal movement
				if move_x != 0:
					x0 += move_x
				else:
					y0 += move_y
				## Alt:
				## Here we prioritize vertical movement when dx and dy are equal
				#if move_y != 0:
					#y0 += move_y
				#elif move_x != 0:  # This check is technically redundant but added for clarity
					#x0 += move_x

			_tiles.push_back(Vector2i(x0, y0))

		parent.view_changed({
			'type': GUIController.Actions.Explore,
			'state': 'moving',
			'coords': coords,
			'tiles': _tiles,
		})

# Called when the node enters the scene tree for the first time.
func handle_release(coords: Vector2i):
	if is_executing:
		_end = coords

		parent.view_changed({
			'type': GUIController.Actions.Explore,
			'state': 'placed',# this is place request
			'coords': coords,
			'tiles': _tiles,
		})

		#for tile_coords in _tiles:
			## TODO: populate the queue for Simulation to expand mycelium one by one
			#LevelController.get_level_controller().place_mycelium_at_coords(tile_coords)
		#LevelController.get_level_controller().place_mycelium_path(_tiles)

		is_executing = false
		_tiles = []
