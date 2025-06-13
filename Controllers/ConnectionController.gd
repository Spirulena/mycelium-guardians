class_name ConnectionController extends Node

var _model: RuinObject
var _connected
var _lc: LevelController

signal connected(object, coords)
signal disconnected(object)

func _init(model):
	_model = model
	_connected = false
	_lc = LevelController.get_level_controller()

func _ready():
	# get all tiles under, and connect to them
	for coords in _model.get_tile_coords():
		_lc.get_tile_at(coords).tile_changed_direct.connect(_on_model_changed)
	#_lc.model_changed.connect(_on_model_changed)
	# Run update for the first time
	update_connection()

# TODO: check does it need to handle mycelium removed
func _on_model_changed(change):
	if (change.type == ModelObject.Type.Mycelium and
		change.curr != null):
			var mycelium: MyceliumObject = change.curr
			mycelium.state_changed.connect(_on_mycelium_state_changed) # can bind coords
	elif (change.type == ModelObject.Type.Mycelium and
		change.prev != null):
			var mycelium: MyceliumObject = change.prev
			# TODO: check if connected
			if mycelium.state_changed.is_connected(_on_mycelium_state_changed):
				mycelium.state_changed.disconnect(_on_mycelium_state_changed) # can bind coords
			if _connected:
				pass
				#print(change)
			update_connection()

func _on_mycelium_state_changed(change):
	if change.prop == 'state' and change.curr == MyceliumObject.MyceliumState.Idle:
		await get_tree().process_frame
		update_connection() # can pass change.coords,
		# not really should disconnect as it might be removed then re-added
		## disconnect from tile
		#for coords in _model.get_tile_coords():
			#_lc.get_tile_at(coords).tile_changed_direct.disconnect(_on_model_changed)
		## can queue free connector

# react to mycelium grown, from level_controller
# or to tile under the ruin, and its model_changed signal
# could add tile.mycelium_grown signal in TileObject

func update_connection():
	_lc.paths_computer.update_paths() #TODO: see why we need it here
	await get_tree().process_frame
	await get_tree().process_frame
	var connected_now = false
	var connection_cords

	for coords in _model.get_tile_coords():
		if _lc.connected_to_base(coords):
			connected_now = true
			connection_cords = coords
			break

	if not _connected and connected_now:
		_connected = true
		# Where to update the mode ?
		_lc.set_connected(_model.get_coords(), connection_cords, _model, _connected)
		# this no, no ?
		# _model.set_connected(_connected)
		connected.emit(_model, connection_cords)

	if _connected and not connected_now:
		_connected = false
		disconnected.emit(_model)
	# could queue free after that ?
