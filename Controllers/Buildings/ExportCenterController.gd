class_name ExportCenterController extends Node

var _lc: LevelController
var _model: BuildingObject
var _timer: Timer

var resource_levels_sum = {
	ResourceObject.ResourceType.Water: 0,
	ResourceObject.ResourceType.Minerals: 0,
}

func _init(model, lc):
	_lc = lc
	_model = model
	_model.processing_coords_amount = 0
	_model.process_coords = []
	_model.energy_consumption = 0.01

func _ready():
	name = "ExportCenterController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

	_timer = Timer.new()
	_timer.wait_time = 1.0  # Set the timer to tick every second
	_timer.autostart = false
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

	_model.view_changed.connect(_on_view_changed)
	_model.state_changed.connect(_on_state_changed)

func _on_timer_timeout():
	if _model.export_enabled:
		_on_resource_delivery_tick()
		_model.total_accumulated_carbon = calculate_total_accumulated_carbon()
		_model.smog_penalty_percent_avg = calculate_avg_smog_penalty()
		#auto_collect_carbon_if_storage_present()

func auto_collect_carbon_if_storage_present():
	if _lc.is_carbon_storage_nearby(_model.get_coords(), _model.radius):
		# TODO: move the responsibility to carbon storage. Also add rate calculations.
		collect_all_carbon()

func _on_resource_delivery_tick():
	var all_tiles = _lc.get_mycelium_coords_in_circle(_model.get_coords(), _model.radius)  # Assuming this gets all relevant tiles
	_model.export_tiles_amount = all_tiles.size()

	# reset counters
	for resource_type in resource_levels_sum.keys():
		resource_levels_sum[resource_type] = 0

	for coords in all_tiles:
		var tile = _lc.get_tile_at(coords)
		for resource_type in _model.desired_resource_levels.keys():
			var current_colony_tally = _lc.get_tally(resource_type)
			var current_level = tile.get_resource_level(resource_type)
			var desired_level = _model.desired_resource_levels[resource_type]
			# save desired export level in tile
			tile._desired_resource_levels[resource_type] = desired_level
			var difference = desired_level - current_level

			if difference > 0 and tile.can_receive_resources():
				var amount_to_add = min(difference, calculate_addition_rate(resource_type, difference))

				# Check if the colony has enough resources to add
				if current_colony_tally >= amount_to_add:
					# Deduct the added amount from the colony's tally ?
					_lc.change_tally(resource_type, -amount_to_add)
					# Add the resources to the tile
					tile.change_tally(resource_type, amount_to_add)
				else:
					# Optionally handle the case where there aren't enough resources in the colony
					pass
				# need to have tally at tile,
				# remove from colony ?, then move to tile ?
				# or should I deduce from tile, then from colony tally
				# tile.change_tally(resource_type, amount_to_add)
				# Assuming a method to add resources to a specific tile
			resource_levels_sum[resource_type] += tile.get_resource_level(resource_type)
	# save to model

	for resource_type in resource_levels_sum.keys():
		var actual_avg = resource_levels_sum[resource_type] / _model.export_tiles_amount
		_model.export_resource_levels_percent[resource_type] = actual_avg / max(1, _model.desired_resource_levels[resource_type]) * 100

	# export carbon if have storage and is enabled


func calculate_addition_rate(resource_type, difference):
	# Example logic, adjust as needed for your game
	var rate = difference * 0.33  # Adjust this based on your game's needs
	return rate if rate > 0.01 else difference  # Avoid adding extremely small amounts

#func calculate_addition_rate(resource_type, difference):
	## This is a simple placeholder function. You could add logic here
	## based on various game mechanics, like mycelium efficiency or other factors.
	#return difference * 0.3  # Example: add half of the needed difference per tick

func _clear_desired_level_in_tiles(tiles):
	for coords in tiles:
		for resource_type in _model.desired_resource_levels.keys():
			_lc.get_tile_at(coords)._desired_resource_levels[resource_type] = 0

func _on_view_changed(change):
	# check for radius change, when smaller clear desired levels
	#var all_tiles = _lc.get_mycelium_coords_in_circle(_model.get_coords(), _model.radius)
	# this have to change, so we connect directly to avoid all export centers handling that
	if change.type == 'UI' and change.prop == 'export' and change.model == _model:
		if change.curr == true:
			activate()
		elif change.curr == false:
			deactivate()
	elif change.type == 'UI' and change.prop == 'import' and change.model == _model:
		collect_all_carbon()
	elif  change.type == 'UI' and change.prop == 'export_expand_radius' and change.model == _model:
		expand_to_cover_radius()
	elif change.type == 'set_value' and change.prop == 'radius': # update radius
		if change.curr < change.prev:
			#var all_tiles = _lc.get_mycelium_coords_in_circle(_model.get_coords(), change.prev)
			var all_tiles = _lc.get_coords_in_circle(_model.get_coords(), change.prev)
			_clear_desired_level_in_tiles(all_tiles)
		# scale the size as well of scene

func expand_to_cover_radius():
	# check if already covered
	var all_tiles = _lc.get_coords_in_circle(_model.get_coords(), _model.radius)
	_lc.place_mycelium_path(all_tiles)

func _on_state_changed(change):
	if change.prop == 'state':
		if change.curr == BuildingObject.BuildingState.Done:
			activate()
		elif change.curr == ModelObject.State.Removed:
			deactivate()

func activate():
	_model.set_production_active(true)
	_model.set_value("export_enabled", true)
	_timer.start()

func deactivate():
	_model.set_value("export_enabled", false)
	_model.set_production_active(false)
	_timer.stop()
	var all_tiles = _lc.get_coords_in_circle(_model.get_coords(), _model.get_radius())
	_clear_desired_level_in_tiles(all_tiles)

#func export_resources():
	#var has_water_storage = _lc.check_for_storage_type_nearby(ResourceObject.ResourceType.Water) #pass model or coords ?, radius of search
	#var has_minerals_storage = _model.check_for_storage_type_nearby(ResourceObject.ResourceType.Minerals)# or in func in BuildingObject

	#if has_water_storage:
		#pass # Export water logic here
	#if has_minerals_storage:
		#pass # Export minerals logic here

func collect_all_carbon():
	var all_plants_coords: Array[Vector2i] = _lc.get_plants_coords_in_circle(_model.get_coords(), _model.radius)
	var total_carbon: float = 0.0
	for plant_coords in all_plants_coords:
		var plant_object = _lc.get_tile_at(plant_coords).get_overground()
		total_carbon += plant_object.collect_carbon()
	# Add total_carbon to the player's resources or another relevant tally
	_lc.change_tally(ResourceObject.ResourceType.Carbon, total_carbon)

func calculate_total_accumulated_carbon() -> float:
	var all_coords: Array[Vector2i] = _lc.get_mycelium_coords_in_circle(_model.get_coords(), _model.radius)
	var total_carbon: float = 0.0
	for coords in all_coords:
		var tile: TileObject = _lc.get_tile_at(coords)
		tile._resources[ResourceObject.ResourceType.Carbon]
		total_carbon += tile._resources[ResourceObject.ResourceType.Carbon]  # Assume carbon_accumulated is accessible
	return total_carbon

func calculate_avg_smog_penalty() -> float:
	var all_plants_coords: Array[Vector2i] = _lc.get_plants_coords_in_circle(_model.get_coords(), _model.radius)
	var total_smog: float = 0.0
	for plant_coords in all_plants_coords:
		var plant_object: PlantObject = _lc.get_tile_at(plant_coords).get_overground()
		total_smog += plant_object.smog_penalty_percent # Assume carbon_accumulated is accessible
	return total_smog / max(1, all_plants_coords.size())
