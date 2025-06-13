class_name FFCrasherController extends Node

var _model: CreatureObject
var _state: FFCrasherState
var _prev_state: FFCrasherState
var _map_presenter: FFCrasherMapPresenter
var _lc: LevelController

func _init(model, map_presenter):
	_model = model
	_map_presenter = map_presenter

	_lc = LevelController.get_level_controller()

	# TODO: Use the model object state for this, then map back to state machine
	_prev_state = null
	_state = FFCrasherStateBackAndForth.new(_model, Vector2i(-40, 0))

	_model.set_direction(_state.get_next().direction)
	_model.movable_changed.connect(_movable_changed)

func _movable_changed(change):
	if change.type == 'tile':
		#was called by set_coords
		# here it is about to change, and move to next tile
		# t == 0
		#print(change)
		pass

	if change.type == 'direction':
		#print(change.movement.v)
		#print(change)
		# TODO: check objects below, then kill what is under.

		for coords in _model.get_tile_coords():
			# Need only plants, worms,
			var tile: TileObject = _lc.get_tile_at(coords)
			var plant = tile.get_plant()
			if plant != null:
				plant.set_state(PlantObject.PlantState.Crashed)
			var mycelium = tile.get_mycelium()
			if mycelium != null:
				# or make it crashed. darker,
				mycelium.set_state(ModelObject.State.Crashed)
				#_lc.remove_object(mycelium)
			var creature: CreatureObject = _lc.get_movable_at_coords(coords)
			if creature != null:
				_lc.remove_movable(creature)

			# TODO:
			#ModelObject.Type.Creature:
				#_lc.remove_object(o)

func _ready():
	pass

func _process(delta):
	var coords = _model.get_coords()
	if coords == null:
		return
	var movement = _model.get_movement()

	# track _prev_state
	if _state is FFCrasherStateSignalObstacle and _prev_state != _state and _prev_state != null: # and _prev_state
		print_debug("Entered FFCrasherStateSignalObstacle, will launch a flare")
		_prev_state = null # reset, that is ugly, will not need when move to ModelObject.set_state
		_map_presenter.launch_flare()
		# Communicate to Presenter
	if _state is FFCrasherStateSelfDestruct and _prev_state != _state and _prev_state != null:
		print_debug("Entered FFCrasherStateSelfDestruct, will explode")
		_prev_state = null
		_map_presenter.self_destruct()

		await get_tree().create_timer(0.1).timeout
		# Delete objects in radius.
		# Get center coord of the crasher
		var ff_tiles = _model.get_tile_coords()
		var center_tile = find_center_tile(ff_tiles)
		var to_explode: = _lc.get_coords_in_circle(center_tile, 5)
		for coords_to_explode in to_explode:
			_lc.remove_at_coords(coords_to_explode)
		_lc.remove_movable(_model)
		queue_free()

	movement.t += delta * _model.get_speed()
	if movement.t <= 1:
		_model.update_movement(movement.t)
	else:
		_model.set_coords(coords + movement.v)
		var next = _state.get_next()
		# would prefer to have set_state, to emit state change
		if next.state != _state:
			_prev_state = _state
		_state = next.state
		_model.set_direction(next.direction)

func find_center_tile(tiles):
	var sum_x = 0
	var sum_y = 0
	for tile in tiles:
		sum_x += tile.x
		sum_y += tile.y
	var avg_x = sum_x / tiles.size()
	var avg_y = sum_y / tiles.size()
	var center_point = Vector2i(round(avg_x), round(avg_y))
	return center_point
