class_name MyceliumController extends Node2D

var _model: MyceliumObject
var _tile: TileObject
var _lc: LevelController
var _neighbours: Dictionary
var _timer: Timer
var _extraction_rate: float # move to model ?
var _extraction_scaling: float
var _have_ruin_under: bool
var auto_harvest: bool = false

func _init(model):
	_model = model
	_lc = LevelController.get_level_controller()
	_tile = _lc.get_tile_at(model.get_coords())
	_tile.tile_changed.connect(_tile_changed)
	_model.state_changed.connect(_state_changed)
	_model.health_changed.connect(_health_changed)
	name = "MyceliumController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	_neighbours = {
		Vector2i.UP: false,
		Vector2i.DOWN: false,
		Vector2i.LEFT: false,
		Vector2i.RIGHT: false,
	}
	_extraction_rate = 0.5
	_extraction_scaling = 0.1
	_have_ruin_under = false

func _health_changed(change):
	pass

func _tile_changed(change):
	pass

func _ready():
	if _model.get_state() == ModelObject.State.None:
		await get_tree().process_frame
		_model.set_state(MyceliumObject.MyceliumState.Idle)
	var overground = _tile.get_overground()
	if overground != null and overground.get_type() == ModelObject.Type.Ruin:
		_have_ruin_under = true
		extractable_resources.append(ResourceObject.ResourceType.Minerals)
		# To avoild eating minerals from export center
		# but on ruins we can do that


func _init_timer(callable_function: Callable):
	_timer = Timer.new()
	_timer.name = "mycelium_timer_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	_timer.timeout.connect(callable_function)
	add_child(_timer)

# check do we have water to extract. if so enable timer for processing.
func is_water_available():
	return _lc.get_water_level(_model.get_coords()) > 0

# TODO: this can run once for all tiles, sum up all water, factor it
func start_processing_water():
	_init_timer(process_water)
	_timer.start()

func start_processing_extraction():
	_init_timer(process_resource_extraction)
	_timer.start()

func is_resource_available(resource_type: ResourceObject.ResourceType, coords: Vector2i):
	return true

func process_water():
	if not Global.settings.get('mycelium').get('process_water'):
		return
	var resource_type = ResourceObject.ResourceType.Water

	var extracted: float = 0.0
	if is_water_available():
		var water_level = _lc.get_water_level(_model.get_coords())
		extracted += _lc.get_water_level(_model.get_coords()) * _extraction_rate * _extraction_scaling
		# todo change _tally
		#_lc.change_tally(ResourceObject.ResourceType.Water, +extracted)
		# tile can add to colony to the limit of mycelium storage, then keep reminder in tile

		if extracted > 0:
			# Update the tile's tally with extracted resources
			var colony_limit = _lc.get_tally_storage_limit(resource_type)
			var colony_amount = _lc.get_tally(resource_type)
			var space = colony_limit - colony_amount
			var reminder = space - extracted
			if reminder < 0:
				var to_distribute = extracted - space
				_tile.change_tally(resource_type, to_distribute)
			else:
				#var to_colony: float = max(0, space)
				var to_tile = extracted * 0.1
				var to_colony = extracted * 0.9
				_tile.change_tally(resource_type, to_tile)
				_lc.change_tally(resource_type, to_colony)

		#_tile.change_tally(ResourceObject.ResourceType.Water, +extracted)

var extractable_resources = [ResourceObject.ResourceType.Carbon, ResourceObject.ResourceType.Energy]
func process_resource_extraction():
	if not Global.settings.get('mycelium').get('process_resource_extraction'):
		return
	# Define or retrieve the list of extractable resources

	for resource_type in extractable_resources:
		var extracted: float = 0.0
		var extraction_available = check_resource_availability(resource_type)

		if extraction_available:
			var resource_level = _tile.get_tally(resource_type) #_lc.get_resource_level(_model.get_coords(), resource_type)
			var extraction_rate = get_extraction_rate_for_resource(resource_type)
			extracted += resource_level * extraction_rate

			if extracted > 0:
				# Update the tile's tally with extracted resources
				var colony_limit = _lc.get_tally_storage_limit(resource_type)
				var colony_amount = _lc.get_tally(resource_type)
				var space = colony_limit - colony_amount
				var reminder = space - extracted
				if space < 0:
					var to_distribute = extracted - space
					_tile.change_tally(resource_type, to_distribute)
				else:
					var to_colony: float = max(0, space)
					_lc.change_tally(resource_type, extracted)

func check_resource_availability(resource_type):
	# Placeholder for actual availability check
	# This could involve checking environmental conditions, resource presence, etc.
	return true  # For simplicity, always return true here

# CUT ?
var _mineral_extraction_rate: float = 0.5
var _mineral_extraction_scaling: float = 0.12
var _energy_extraction_rate: float = 0.4
var _energy_extraction_scaling: float = 0.15

# In Custom Resource ?
func get_extraction_rate_for_resource(resource_type):
	# Placeholder for extraction rate retrieval
	# This would return different rates based on the resource type
	match resource_type:
		ResourceObject.ResourceType.Water:
			return _extraction_rate * _extraction_scaling
		ResourceObject.ResourceType.Carbon:
			return _extraction_rate * _extraction_scaling
		ResourceObject.ResourceType.Minerals:
			# Assuming different rates and scaling for demonstration
			return _mineral_extraction_rate * _mineral_extraction_scaling
		ResourceObject.ResourceType.Energy:
			return _energy_extraction_rate * _energy_extraction_scaling
	return 0  # Default case if no match

func _state_changed(change):
	if change.curr == ModelObject.State.Removed:
		queue_free()
	elif change.curr == MyceliumObject.MyceliumState.Idle:
		_lc.get_tile_at(_model.get_coords()).set_discovered_in_radius(true, 5)
		# Add mycelium Storage
		_lc.paths_computer.queue_update_paths()
		for resource_type in ResourceObject.ResourceType.values():
			_lc.change_tally_storage_limit(resource_type, _model.get_storage_limit(resource_type), _model)

		# check of there is a resource
		# add harvester if there is none
		var tile = _lc.get_tile_at(_model.get_coords())
		if auto_harvest and tile.get_resource() != null:
			if tile.get_harvester() == null:
				# could use tile.add_object
				_lc.add_object_guarded(HarvesterObject.new(_model.get_coords()))
		if is_water_available():
			start_processing_water()
		start_processing_extraction()
		#start_processing_extraction() # for this to work, need to change HarvesterController
		set_process(false)
	elif change.curr == MyceliumObject.MyceliumState.ReleasingAcid:
		set_process(true)

# lets make release acid separate controller, so we can add it when needed, then remove.
#func _process(delta):
	### Releasing acid
	#if _model.get_state() == MyceliumObject.MyceliumState.ReleasingAcid:
		#var ai_panel = _lc.get_tile_at(_model.get_coords()).get_type(ModelObject.Type.AIPanel)
#
		#var acid_amount = _lc.get_acid_rate() * delta * 10
		#var health_amount = acid_amount
		#var mineral_amount = health_amount
#
		#if ai_panel != null and _lc.change_tally(ResourceObject.ResourceType.Acid, -acid_amount):
			#if ai_panel.change_health(-health_amount):
				#_lc.change_tally(ResourceObject.ResourceType.Minerals, +mineral_amount)
		#elif ai_panel == null:
			#_model.set_state(MyceliumObject.MyceliumState.Idle)

func get_neighbours():
	if _model.get_coords() in _lc.get_base_coords():
		_neighbours = {
			Vector2i.UP: true,
			Vector2i.DOWN: true,
			Vector2i.LEFT: true,
			Vector2i.RIGHT: true,
		}
		return _neighbours

	var coords = _model.get_coords()
	for direction in _neighbours.keys():
		_neighbours[direction] = _lc.have_neighbor_to(coords, direction)
	return _neighbours
