class_name StorageController extends Node

var _lc: LevelController
var _model: BuildingObject
var timer: Timer
var _resource_type: ResourceObject.ResourceType

func _init(model, lc):
	_lc = lc
	_model = model
	_resource_type = _model.get_resource_stored_type()
	# storage type in _resource_storage_type or get_resource_storage_type

func _ready():
	_model.state_changed.connect(_on_state_changed)
	name = "StorageController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	# for continous absorbtion
	timer = Timer.new()
	timer.wait_time = 1.0  # Set the timer to tick every second
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	_model.view_changed.connect(_on_view_changed)

func _on_state_changed(change):
	if change.prop == 'state':
		if change.curr == BuildingObject.BuildingState.Done:
			activate()
		elif change.curr == ModelObject.State.Removed:
			deactivate()

func activate():
	_model.set_production_active(true)
	timer.start()

func deactivate():
	_model.set_production_active(false)
	timer.stop()

func _on_timer_timeout():
	apply_production()

func _on_view_changed(change):
	if change.type == 'UI' and change.prop == 'production':
		if change.curr == true:
			activate()
		elif change.curr == false:
			deactivate()

func collect_water2():
	var radius = _model.get_value("radius")  # Define your collection radius
	var center_coords = _model.get_coords()
	var all_coords: Array[Vector2i] = _lc.get_coords_in_circle(center_coords, radius)
	var total_collected_resource: float = 0.0
	var tiles_amount: int = 0
	var colony_limit = _lc.get_tally_storage_limit(_resource_type)  # The overall limit for this resource in the colony
	var current_colony_tally = _lc.get_tally(_resource_type)  # Current amount of resource in the colony
	var structure_limit = _model.get_default_storage_amount()  # The limit specific to this structure
	var current_structure_storage = _model.resource_store[_resource_type]  # Current amount stored in this structure

	# Calculate how much more can be collected without exceeding limits
	var available_colony_capacity = colony_limit - current_colony_tally
	var available_structure_capacity = structure_limit - current_structure_storage # ignore for now.
	#var available_structure_capacity = available_colony_capacity
	var collectible_limit = min(available_colony_capacity, available_structure_capacity)

	for coords in all_coords:
		if total_collected_resource >= collectible_limit:
			break  # Stop collecting if we've reached the collectible limit

		var distance = center_coords.distance_to(coords)
		var efficiency = calculate_collection_efficiency(distance)
		var tile_object = _lc.get_tile_at(coords)
		var resource_amount = tile_object.get_tally(_resource_type)
		var tile_max_storage = tile_object.get_max_tile_storage(_resource_type)
		var export_level = tile_object._desired_resource_levels.get(_resource_type, 0)
		var excess = resource_amount - max(tile_max_storage, export_level)

		if excess > 0:
			var collected = min(excess * efficiency, collectible_limit - total_collected_resource)
			total_collected_resource += collected
			tile_object.change_tally(_resource_type, -collected)  # Remove collected resources from tile
			tiles_amount += 1

	# Update the resources, respecting the calculated limit
	#_lc.change_tally(_resource_type, total_collected_resource)
	_model.resource_store[_resource_type] += total_collected_resource
	_model.last_resource_input[_resource_type] = total_collected_resource
	_model.set_value("processing_coords_amount", tiles_amount)

func collect_water():
	var radius = _model.get_value("radius")
	var center_coords = _model.get_coords()
	var all_coords: Array[Vector2i] = _lc.get_coords_in_circle(center_coords, radius)
	var total_collected_resource: float = 0.0
	var tiles_amount: int = 0

	for coords in all_coords:
		var distance = center_coords.distance_to(coords)
		var efficiency = calculate_collection_efficiency(distance)
		var tile_object = _lc.get_tile_at(coords)
		var resource_amount = tile_object.get_tally(_resource_type)
		var tile_max_storage = tile_object.get_max_tile_storage(_resource_type)
		var export_level = tile_object._desired_resource_levels.get(_resource_type, 0)
		var excess = resource_amount - max(tile_max_storage, export_level)

		if excess > 0:
			var collected = excess * efficiency
			total_collected_resource += collected
			tile_object.change_tally(_resource_type, -collected)  # Remove collected resources from tile
			tiles_amount += 1

	# After collecting, distribute resources
	distribute_collected_resources(total_collected_resource)
	_model.set_value("processing_coords_amount", tiles_amount)

func distribute_collected_resources(total_collected_resource: float):
	var available_colony_capacity = _lc.get_tally_storage_limit(_resource_type) - _lc.get_tally(_resource_type)
	var amount_to_mycelium = min(total_collected_resource, available_colony_capacity)

	# Update the mycelium tally with the amount that can be accommodated
	if amount_to_mycelium > 0:
		_lc.change_tally(_resource_type, amount_to_mycelium)
		total_collected_resource -= amount_to_mycelium

	# If there's still collected resource left, add it to the sclerotia storage
	if total_collected_resource > 0:
		_model.resource_store[_resource_type] += total_collected_resource
		_model.last_resource_input[_resource_type] = total_collected_resource
		# Remember to update any relevant totals or limits for sclerotia storage
	_lc.level_data.update_storage_tally()

# this is for plants and carbon,
# Need to add general water, energy, minerals collectors
func collect_resources_with_distance_penalty():
	var radius = _model.get_value("radius")  # Define your collection radius
	var center_coords = _model.get_coords()
	var all_coords: Array[Vector2i] = _lc.get_coords_in_circle(center_coords, radius)
	var total_collected_resource: float = 0.0
	var tiles_amount: int = 0

	for coords in all_coords:
		var tile_object = _lc.get_tile_at(coords)
		var resource_amount = tile_object.get_tally(_resource_type)
		var tile_max_storage = tile_object.get_max_tile_storage(_resource_type)
		var excess = resource_amount - 0.1

		if excess > 0:
			var distance = center_coords.distance_to(coords)
			var efficiency = calculate_collection_efficiency(distance)
			var collected = excess * efficiency

			total_collected_resource += collected
			tile_object.change_tally(_resource_type, -collected)  # Remove collected resources from tile
			tiles_amount += 1

	# Here, update your model or game state with the collected resource
	#_lc.change_tally(_resource_type, total_collected_resource)

	# should use change_structure_tally
	_model.resource_store[_resource_type] += total_collected_resource
	_model.last_resource_input[_resource_type] = total_collected_resource
	_model.set_value("processing_coords_amount", tiles_amount)
	# _model.change_resource_tally(_resource_type, total_collected_resource)
	# this would be mycelium or rather internal storage

func calculate_collection_efficiency(distance) -> float:
	var max_efficiency = 1.0  # 100% efficiency at distance 0
	var min_efficiency = 0.5  # 50% minimum efficiency
	var efficiency_decrease_per_tile = 0.05  # Efficiency decrease per tile
	var efficiency = max_efficiency - (distance * efficiency_decrease_per_tile)
	return max(min_efficiency, efficiency)

func apply_production():
	if _resource_type == ResourceObject.ResourceType.Carbon: # this should also collect from tiles, not only plants
		#collect_resources_with_distance_penalty()
		collect_water()
	if _resource_type == ResourceObject.ResourceType.Water:
		collect_water()
	if _resource_type == ResourceObject.ResourceType.Energy:
		collect_water()
	if _resource_type == ResourceObject.ResourceType.Minerals:
		collect_water()

	# Add else if blocks for other resource types if necessary
