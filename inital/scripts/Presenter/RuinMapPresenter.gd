class_name RuinMapPresenter extends Node2D

var _model: RuinObject
var _parent
var _connection_controller: ConnectionController # that is the connection controller.
var _controller: RuinController
var _instance
var _covered_with_mycelium: bool
var _lc: LevelController

func _init(model, parent, controller):
	_model = model
	_parent = parent
	_connection_controller = controller
	_instance = null
	_covered_with_mycelium = false
	_controller = null

func _ready():
	_lc = LevelController.get_level_controller()
	var type = _model.get_ruin_type()
	_instance = Loader.get_loader().return_scene(type).instantiate()
	self.position = _parent.to_position(_model.get_coords())

	self.name = "ruins_%s_%d_%d" % [type, _model.get_coords().x, _model.get_coords().y]
	self.y_sort_enabled = true

	add_child(_instance)
	add_child(_connection_controller)
	_connection_controller.connected.connect(on_mycelium_connected)
	apply_visibility()

	_controller = RuinController.new(_model)
	add_child(_controller)

	_model.state_changed.connect(_state_changed)
	# connect to tile to monitor discovered
	for tile_coords in _model.get_tile_coords():
		var tile = _lc.get_tile_at(tile_coords)
		tile.tile_changed_direct.connect(_tile_changed_direct)

func show_connection_point():
	pass

func _state_changed(change):
	#print(change)
	if change.curr == ModelObject.State.Removed:
		# We are missing, Controller reacting to resource change
		# TODO: add fade out
		var alpha_tween: Tween = self.create_tween()
		alpha_tween.tween_property(self, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_OUT)
		alpha_tween.tween_callback(queue_free)


func apply_visibility():
	# TODO: check all coords
	var discovered:bool = false
	var all_coords = _model.get_tile_coords()
	for coords in all_coords:
		var tile:TileObject = _lc.get_tile_at(coords)
		if  tile.get_discovered():
			discovered = true
			break

	#var coords = _model.get_coords()

	if not discovered:
		# for init
		_instance.modulate.a = 0.0
		_instance.visible = false
	else:
		if is_equal_approx(_instance.modulate.a, 1.0):
			return
		# ignore if modulate.a is already 1.
		_instance.visible = discovered
		var alpha_tween = _instance.create_tween() as Tween
		alpha_tween.tween_property(_instance, "modulate:a", 1.0, 2)

# PERF: FIX: That should be in one place and then send here with specific signal.
# Signal for discovered changed ?
# Now it needs to check each signal
# Better: Connect to tiles under with the direct, and
# With tile_changed_direct discovered changed. this will be only few signals
# Do it now
func _tile_changed_direct(change):
	if change.type == 'discovered':
		if change.curr == true:
			apply_visibility()
			# then disconnect all tiles, or ingore any further changes
				# connect to tile to monitor discovered
			# disconnet here.
			# later might want to keep monitoring

			# disconnect just one
			#var tile = _lc.get_tile_at(change.coords)
			#tile.tile_changed_direct.disconnect(_tile_changed_direct)

			# or all
			for coords in _model.get_tile_coords():
				var tile = _lc.get_tile_at(coords)
				tile.tile_changed_direct.disconnect(_tile_changed_direct)

# Sill, player needs to click decompose 1st to get that to happen

func on_mycelium_connected(_model, connection_cords: Vector2i):
	#grow_over(_model, connection_cords)
	show_action_buttons(_model, connection_cords)

func show_action_buttons(_model, connection_cords):
	pass
	# check which actions we have
	init_decompose_button(_model, connection_cords)

var decompose_button: DecomposeButton
func init_decompose_button(_model, connection_cords):
	decompose_button = Loader.get_loader().return_scene("decompose_button").instantiate()
	decompose_button.pressed.connect(on_decompose_button_pressed.bind(_model, connection_cords, decompose_button))
	add_child(decompose_button)

func on_decompose_button_pressed(_model, connection_cords, button):
	#In LevelController
	#if change.type == 'ConnectionToBase':
		##print_debug(change)
		## TODO: if that is ruin it should be after player requests harvesting
		#if change.object.get_type() == ModelObject.Type.Ruin and change.prev == false and change.curr == true:
	# For now tread organic matter separatelly, it is the only one that have few resources in same tile
	if _model.get_ruin_type() == 'ruin_organic_matter':
		# special case for now
		pass
		# Timer, and change tally to just add resources there ?
		for resource in _model.get_resources():
			var res: ResourceObject = resource
			var coords: Vector2i = resource.get_coords()
			var tile: TileObject = _lc.get_tile_at(coords)
			# Then how will it be removed ? Harvester was doing that.
			# either fix harvester, meaning allow for multiple ones
			# or i dunno, I am just working around the previous tech.
			_lc.change_tally(res.get_resource_type(), res.get_resource_amount())
			res.change_resource_amount(-res.get_resource_amount()) # This should ensure resource will be deleted
		# then delete ruin
		#button.queue_free() # DecomposeButton queue itself after clicked for now.
		_model.set_state(ModelObject.State.Removed)
	else:
		_lc.harvest_ruin(_model)
		_lc.expand_mycelium_under_ruin(_model)

		grow_over(_model, connection_cords)
		#button.queue_free()

# TODO: LevelData should have mycelium_cover_status 0-100. Controller should drive that.
# Presenter just progress over animation based on that value
func grow_over(_model, connection_cords):
	if not _covered_with_mycelium:
		if _instance.has_method("play_cover"):
			_instance.play_cover()
		else:
			print_debug("Add play cover to ruin")
		_covered_with_mycelium = true
	# FIXME:
	# start extracting resources, based on enzyme decomposition of ruin
