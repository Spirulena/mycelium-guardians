class_name LevelController extends Node2D

static var level_controller

var paths_computer: PathsComputer
var level_data: LevelData

static func get_level_controller() -> LevelController:
	if not is_instance_valid(level_controller):
		level_controller = LevelController.new()
	return level_controller

# TODO: offload current signals to act on data here - grow_building_at_tile_started
# TODO: leave the spawning from change_array

signal model_changed(change: Dictionary)

var ticks: Dictionary
# Move to LevelData
var resource_history = {} # Dictionary of resource types to lists of (timestamp, tally) tuples
const SAMPLE_INTERVAL = 1.0 # Interval in seconds between samples
const SAMPLE_DURATION = 5.0 # Duration in seconds to keep samples
const MARGIN = 2
const EQUILIBRIUM_MARGIN = 10 # can be scaled as colony extends
# or a factor number, the difference size ?

var auto_expand_mycelium_towards_water:bool
var auto_harvest_ruins: bool = false

func _init():
	name = "LevelController"
	paths_computer = PathsComputer.new(self)
	level_data = LevelData.new() as LevelData
	level_data.model_changed.connect(_model_changed)
	# Initialize resource_history for each resource type
	for resource_type in ResourceObject.ResourceType.values():
		resource_history[resource_type] = []
	auto_expand_mycelium_towards_water = true

func set_ignore_water_noise(val: bool):
	level_data.set_ignore_water_noise(val)

# SMOG_LEVEL_EDITOR
func set_config(key, val):
	level_data.set_config(key, val)

func get_config(key):
	return level_data.get_config(key)

func update_seed(seed: int) -> void:
	level_data.update_seed(seed)
	# TODO: make ruins also dependant on seed

func get_enzymes(key):
	return level_data.get_enzymes(key)

func set_enzymes(key, value):
	level_data.set_enzymes(key, value)

func get_enzymes_amount() -> float:
	return level_data.get_enzymes_amount()

func set_enzymes_amount(amount) -> bool:
	return level_data.set_enzymes_amount(amount)

func change_enzymes_amount(amount) -> bool:
	return level_data.change_enzymes_amount(amount)

func get_water_level(coords: Vector2i) -> float:
	return level_data.get_water_level(coords)

func get_coords_in_radius(coords: Vector2i, radius: int) -> Array[Vector2i]:
	var return_cords: Array[Vector2i] = []

	for dx in range(coords.x - radius, coords.x + radius + 1):
		for dy in range(coords.y - radius, coords.y + radius + 1):
			return_cords.push_back(Vector2i(dx, dy))

	if return_cords.size() == 1:
		return_cords = []

	return return_cords

func get_plants_coords_in_circle(coords: Vector2i, radius: int) -> Array[Vector2i]:
	var plants:Array[Vector2i] = []
	var base_coords = get_base_coords()
	var all_coords = get_coords_in_circle(coords, radius)
	for candidate in all_coords:
		if is_plant_at(candidate) and not (candidate in base_coords):
			plants.append(candidate)
	return plants

# TODO: get_mycelium_in_circle
# rename get_mycelium_coords_in_circle
func get_mycelium_coords_in_circle(coords: Vector2i, radius: int) -> Array[Vector2i]:
	var mycelium:Array[Vector2i] = []
	var base_coords = get_base_coords()
	var all_coords = get_coords_in_circle(coords, radius)
	for candidate in all_coords:
		if is_mycelium_at(candidate) and not (candidate in base_coords):
			mycelium.append(candidate)
	return mycelium

# NOTE: test this
func get_coords_in_circle(coords: Vector2i, radius: int) -> Array[Vector2i]:
	var return_coords: Array[Vector2i] = []
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				return_coords.push_back(coords + Vector2i(dx, dy))

	return return_coords

### Model changed
func _model_changed(change: Dictionary):
	model_changed.emit(change)

	# Act on changes
	if change.type == ModelObject.Type.Mycelium:
		paths_computer.queue_update_paths()

		if change.curr == null:
			pass
		elif change.prev == null:
			# add resource from the noise map
			#var resource_type = get_noise_resource_type_at(change.coords)
			#if  resource_type != null:
				#add_resource( ResourceObject.new(
						#change.coords,
						#get_noise_resource_type_at(change.coords),
						#get_noise_resource_amount_at(resource_type, change.coords)
						#)
				#)

			# Incur cost
			for resource in ResourceObject.ResourceType.values():
				level_data.change_tally(resource, -get_mycelium_growth_cost_at(change.coords)[resource])

	elif change.type == ModelObject.Type.Building and change.curr != null:
		pass

	if change.type == 'ConnectionToBase' and auto_harvest_ruins:
		# NOTE: this is not called, mycelium is adding harvesters
		#print_debug(change)
		# TODO: if that is ruin it should be after player requests harvesting
		if change.object.get_type() == ModelObject.Type.Ruin and change.prev == false and change.curr == true:
			harvest_ruin(change.object)
			expand_mycelium_under_ruin(change.object)
#####
	#if change.type == 'TileObject' and change.curr  != null:
		## new tile
		## Set radiation besed on noise and level data
		#change.curr.set_radiation(level_data.get_radiation_scaled(change.coords))
		## smog base + noise
		## SMOG_LEVEL_EDITOR
		#change.curr.set_smog(level_data.get_smog_scaled(change.coords))



func harvest_ruin(ruin: RuinObject):
	# Change to var resources = change.object.get_resources()
	for resource in ruin.get_resources():
		var coords = resource.get_coords()
		var tile: TileObject = level_controller.get_tile_at(coords)
		var harvester: HarvesterObject = tile.get_harvester() # this returns just one harvester
		if harvester == null:
			harvester = HarvesterObject.new(resource.get_coords())
			add_object_guarded(harvester)
		ruin._harvesters.append(harvester)
		harvester._ruin = ruin

		# harvest_from_coords(resource.get_coords()) # no mycelium there yet

func expand_mycelium_under_ruin(ruin: RuinObject):
	place_mycelium_path(ruin.get_tile_coords())

func _building_state_changed(change: Dictionary):
	if change.prop == 'StorageLimit':
		# Storage: Apply to tally,
		# may not need to check if it i
		if change.object.get_category() == BuildingObject.StructureCategory.Storage:
			pass
			#var add_storage:Dictionary = change.object.get_storage_limit()
				# could use values from change.prev, change.curr, change.resource_type
			#change_tally_storage_limit(change.resource_type, change.curr, change.object)

	if change.prop == 'state':
		if change.curr == BuildingObject.BuildingState.Done:
			pass
			#for coords in change.object.get_smog_absorption_coords():
				#change_smog(coords, -1)
			#for coords in change.object.get_radiation_absorption_coords():
				#change_radiation(coords, -1)

		elif change.curr == BuildingObject.BuildingState.Building:
			# Pay the price of the object ?
			# Would be cool to animate the change, or do it gradually as it grows
			var building_costs = change.object.get_growth_cost()
			for resource_type in building_costs.keys():
				# adjust for radius
				var adjusted_to_radius: float = building_costs[resource_type] * change.object.get_radius()
				change_tally(resource_type, -adjusted_to_radius)

		elif change.curr == ModelObject.State.Removed:
			pass
			#for coords in change.object.get_smog_absorption_coords():
				#change_smog(coords, +1)
			#for coords in change.object.get_radiation_absorption_coords():
				#change_radiation(coords, +1)

			# Emit storageChanged on removed ?
			# Storage
			#if change.object.get_category() == BuildingObject.StructureCategory.Storage:
				#var remove_storage:Dictionary = change.object.get_storage_limit()
				#for storage_type in remove_storage.keys():
					#change_tally_storage_limit(storage_type, -remove_storage[storage_type], change.object)
		# Recycle ?

func get_mycelium_growth_cost_at(coords: Vector2i):
	return get_mycelium_expansion_cost()

func get_mycelium_expansion_cost():
	return level_data.get_mycelium_expansion_cost()

func get_wind_direction():
	return level_data.get_wind_direction()

func get_wind_speed():
	return level_data.get_wind_speed()

func get_wind_vector():
	return level_data.get_wind_vector()

func set_wind_vector(value):
	return level_data.set_wind_vector(value)

func set_wind_direction(value):
	return level_data.set_wind_direction(value)

func does_have_enough_resources_to_expand():
	return true

func have_neighbor_to(coords: Vector2i, to):
	var check_coord = coords + to
	return level_data._grown_mycelium.has(check_coord)

func is_mycelium_at(coords: Vector2i) -> bool:
	return get_tile_at(coords).get_mycelium() != null and get_tile_at(coords).get_mycelium().get_type() == ModelObject.Type.Mycelium

func is_plant_at(coords: Vector2i) -> bool:
	return get_tile_at(coords).get_overground() != null and get_tile_at(coords).get_overground().get_type() == ModelObject.Type.Plant

func is_mycelium_any_at(coords: Vector2i) -> bool:
	var tile = get_tile_at(coords)
	var myc = tile.get_mycelium()
	return myc != null

func is_carbon_storage_nearby(center_coords: Vector2i, radius: int):
	return is_structure_nearby(BuildingObject.StructureType.Storage_Carbon, center_coords, radius)

func is_structure_nearby(structure_type: BuildingObject.StructureType, center_coords: Vector2i, radius: int) -> bool:
	var all_tiles: Array[Vector2i] = get_mycelium_coords_in_circle(center_coords, radius)
	for coords in all_tiles:
		var tile: TileObject = get_tile_at(coords)
		if tile and tile.get_building_type() == structure_type:
			return true  # Structure of type found
			# also return it ?, maybe separate to get structures in radius
	return false  # No structure found

func can_expand_mycelium_at_coords(coords: Vector2i):
	var connected_to_base = paths_computer.neighbors_connected_to_base(coords)
	var tile = get_tile_at(coords)
	var mycelium = tile.get_mycelium()
	# TODO: check if tile is not blocked, lava, end of level, something.
	if mycelium == null and connected_to_base:
		return true
	return false

func place_mycelium_at_coords(coords: Vector2i):
	if not is_mycelium_any_at(coords):
		add_object(MyceliumQueueObject.new(coords))
		return
	return
	print_stack()
	return false
	if is_mycelium_at(coords):
		return false
	add_object(MyceliumQueueObject.new(coords))
	# add queue object
	#add_object(MyceliumObject.new(coords))
	return true

func place_mycelium_path(tiles: Array):
	pass
	for coords in tiles:
		if not is_mycelium_any_at(coords):
			add_object(MyceliumQueueObject.new(coords))
	#print_debug(tiles)
	# MyceliumController could do growth -> idle
	# Then need to not allow expand from ungrown ?
	# Rather not place building on ungrown  ?
	# Or just queue after it is grown ?

	# populate the queue for growth.
	#
	# in porcess, grow each one,
	# Grow from closes mycelium tile, untill all are grown
	#
	pass

func expand_mycelium_at_coords(coords: Vector2i):
	if not does_have_enough_resources_to_expand():
		return false

	if not can_expand_mycelium_at_coords(coords):
		return false

	return place_mycelium_at_coords(coords)

func get_all_mycelium():
	return level_data.get_all_mycelium()

func get_base_coords():
	return level_data.get_base_coords()

func get_tile_at(coords: Vector2i) -> TileObject:
	return level_data.get_tile_at(coords)

func get_extraction_rate_at_coords(coords:Vector2i):
	return level_data.get_extraction_rate_at_coords(coords)

func remove_object(object: ModelObject):
	level_data.remove_object(object)

func remove_movable(object: MovableObject):
	level_data.remove_movable(object)

func remove_at_coords(coords: Vector2i):
	# TODO: this will change when have layers in tile
	# remove building, then mycelium

	# Skip base
	if coords in get_base_coords():
		return false

	# prune plants
	var tile: = get_tile_at(coords)
	var overground = tile.get_overground()
	var mycelium = tile.get_mycelium()
	# Check for plants under
	if overground != null:
		var type = overground.get_type()
		if type == ModelObject.Type.Plant and mycelium != null:
			# TODO: make them decompose first, then get some resources out
			remove_object(overground)
			return

	#var tile = get_tile_at(coords)
	var structure: BuildingObject = tile.get_structure() # this gets overground
	if structure != null:
		remove_object(structure._harvester)
		remove_object(structure._resource)
		remove_object(structure)
		# Recover some costs
		var building_type = structure.get_building_type()
		var radius = structure.get_radius()
		var cost = BuildingObject.get_growth_cost_preview(building_type, radius)
		for resource_type in cost.keys():
			var recycled: float = cost[resource_type] * 0.8
			change_tally(resource_type, +recycled)
		return

	if mycelium != null:
		if mycelium.get_type() == ModelObject.Type.Mycelium:
			remove_object(get_tile_at(coords).get_harvester())
			remove_object(mycelium)
			return true
	print("Nothing to prune")
	return false

# TODO: test this with AIPanels, Creatures, Plants - does try to delete them
# TODO: prune should only remove mycelium.
func can_prune_at_coords(coords: Vector2i) -> bool:
	# TODO: Don't allow base pruning
	if coords in get_base_coords():
		return false
	# TODO: this will change when have layers in tile
	# Can prune: building, mycelium.
	var tile = get_tile_at(coords)
	if tile.get_structure() != null or tile.get_mycelium() != null or tile.get_plant() != null:
		return true
	return false

func prune_at_coords(coords: Vector2i):
	if can_prune_at_coords(coords):
		remove_at_coords(coords)
		return true
	return false

func can_release_acid(coords: Vector2i):
	return get_tile_at(coords).get_type(ModelObject.Type.AIPanel) != null and get_tile_at(coords).get_type(ModelObject.Type.Mycelium) != null

func release_acid(coords: Vector2i):
	if can_release_acid(coords):
		var panel = get_tile_at(coords).get_type(ModelObject.Type.AIPanel)
		var mycelium = get_tile_at(coords).get_type(ModelObject.Type.Mycelium)
		mycelium.set_state(MyceliumObject.MyceliumState.ReleasingAcid)

		return true
	return false

func get_acid_rate():
	return level_data.get_acid_rate()

func can_harvest_from_coords(coords: Vector2i):
	var tile = get_tile_at(coords)
	var is_harvester = tile.get_harvester() != null
	var is_resource = tile.get_resource() != null
	var is_mycelium = tile.get_mycelium() != null and tile.get_mycelium().get_type() == ModelObject.Type.Mycelium
	return is_harvester and is_resource and is_mycelium

func harvest_from_coords(coords: Vector2i):
	if can_harvest_from_coords(coords):
		add_object_guarded(
			# Change, to just coords, resource would be added at tileObject level
			HarvesterObject.new(coords)
		)
		return true

	return false

func get_smog(coords: Vector2i):
	return get_tile_at(coords).get_smog()

func get_radiation(coords: Vector2i):
	return get_tile_at(coords).get_radiation()

# change to change_smog_at ?
func change_smog(coords: Vector2i, amount: float):
	return get_tile_at(coords).change_smog(amount)

func change_radiation(coords: Vector2i, amount):
	return get_tile_at(coords).change_radiation(amount)

func add_object(object: ModelObject):
	level_data.add_object(object)
	object.state_changed.connect(_on_object_state_changed)
	# connect state_changed

func add_movable(object: MovableObject):
	level_data.add_movable(object)

func can_add_movable(object: MovableObject) -> bool:
	var val:bool = true
	var coords: Vector2i = object.get_coords()
	var tile = get_tile_at(coords)
	match object.get_type():
		ModelObject.Type.Creature:
			match object.get_subtype():
				CreatureObject.CreatureType.Worm:
					# rule check is_layer_free(layer_overground, worm)
					# rule layer, who's asking,
					# can pass object, object can store it's layer
					# or can assume for now one object per layer
					# then its layer[overground] != null
					# or layer.has(enum_overground)
					val = val and tile.get_ruin() == null
					val = val and tile.get_structure() == null
					val = val and not coords in get_base_coords()
	return val

func add_movable_guarded(object: MovableObject) -> bool:
	if can_add_movable(object):
		add_movable(object)
		return true
	return false

func _on_object_state_changed(change: Dictionary):
	# if it is mycelium, and moved to state Idle, add to grown mycelium
	if (change.type == ModelObject.Type.Mycelium and change.prop == 'state'
		and change.object.get_state() == MyceliumObject.MyceliumState.Idle):
		var coords = change.object.get_coords()
		level_data._grown_mycelium[coords] = change.object
		# to tile_changed_direct ?
		get_tile_at(coords).tile_changed_direct.emit({
			'type': 'mycelium_grown',
			'coords': coords,
			'prev:': false,
			'curr': true,
		})
		# emit change to model changed ?

func get_grown_mycelium() -> Dictionary:
	return level_data._grown_mycelium

func has_grown_mycelium_at(coords: Vector2i):
	return level_data._grown_mycelium.has(coords)

func has_grown_neighbors(coords: Vector2i):
	var offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for offset in offsets:
		if level_data._grown_mycelium.has(coords + offset):
			return true

	return false

var mycelium_hood_offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
func get_mycelium_hood_coords(coords: Vector2i):
	var list: Array = []
	for offset in mycelium_hood_offsets:
		list.append(coords + offset)
	return list

func get_hood_tiles(coords: Vector2i):
	var tiles:Array = []
	for i_coords in get_mycelium_hood_coords(coords):
		tiles.append(get_tile_at(i_coords))
	return tiles

func add_resource(resource: ResourceObject):
	# shoudl be add_resource -proxy-> level_data.add_resource, but will use add_object_guarded ?
	level_data.add_resource(resource)

# DELETE: ?
func get_resource_at(coords: Vector2i):
	return level_data.get_resource_at(coords)

func get_resources_at(coords: Vector2i):
	return level_data.get_resources_at(coords)

# getting from noise map
func get_noise_resource_amount_at(type, location: Vector2i):
	return level_data.get_noise_resource_amount_at(type, location)
# getting from noise map
func get_noise_resource_type_at(location: Vector2i):
	return level_data.get_noise_resource_type_at(location)

func change_energy(amount):
	change_tally(ResourceObject.ResourceType.Energy, amount)

func change_minerals(amount):
	change_tally(ResourceObject.ResourceType.Minerals, amount)

func change_tally(type: ResourceObject.ResourceType, amount):
	level_data.change_tally(type, amount)

func can_consume_resources(water_needed: float, minerals_needed: float) -> bool:
	var current_water_level = get_tally(ResourceObject.ResourceType.Water)
	var current_minerals_level = get_minerals()
	return current_water_level >= water_needed and current_minerals_level >= minerals_needed

func get_energy():
	return get_tally(ResourceObject.ResourceType.Energy)

func get_minerals():
	return get_tally(ResourceObject.ResourceType.Minerals)

func get_tally(type: ResourceObject.ResourceType):
	return level_data.get_tally(type)

func get_tally_storage_limit(type: ResourceObject.ResourceType):
	return level_data.get_tally_storage_limit(type)

func set_tally_storage_limit(type: ResourceObject.ResourceType, value, model_object: ModelObject):
	return level_data.set_tally_storage_limit(type, value, model_object)

func change_tally_storage_limit(type: ResourceObject.ResourceType, amount, model_object: ModelObject):
	return level_data.change_tally_storage_limit(type, amount, model_object)

func distance_to_base(coords: Vector2i):
	return paths_computer.distance_to_base(coords)

func get_next_to_base(coords: Vector2i):
	return paths_computer.get_next_to_base(coords)

func connected_to_base(coords: Vector2i):
	return paths_computer.connected_to_base(coords)

func calculate_heal_cost(coords: Vector2i) -> Dictionary:
	var degradation_fraction: float = get_mycelium_degredation(coords)/100.0
	degradation_fraction = clamp(degradation_fraction, 0.0, 1.0)
	var heal_costs: Dictionary = {}

	for resource in get_mycelium_growth_cost_at(coords).keys():
		heal_costs[resource] = degradation_fraction * get_mycelium_growth_cost_at(coords)[resource]

	return heal_costs

func set_mycelium_health(coords: Vector2i, health):
	# TODO: issue with not getting mycelium
	level_data.get_mycelium_at(coords).set_health(health)

func get_mycelium_health(coords: Vector2i):
	return level_data.get_mycelium_at(coords).get_health()

func get_mycelium_degredation(coords: Vector2i):
	return level_data.get_mycelium_at(coords).get_degradation()

func heal_tile(coords: Vector2i):
	if not is_mycelium_at(coords):
		return false
	return true

func get_objects_at(coords: Vector2i):
	return level_data.get_objects_at(coords)

func get_all_tiles():
	return level_data.get_all_tiles()

# TODO: Make it a N distance from mycelium
# Mycelium / Colony visibility area
# FIX: time to store it in _dict
func get_all_tiles_visible_by_mycelium():
	# TODO: filter by visible
	var filtered_tiles = {}
	var all_tiles = get_all_tiles()
	for coords in all_tiles.keys():
		if is_tile_visible_by_mycelium(all_tiles[coords]):
			filtered_tiles[coords] = all_tiles[coords]
	return filtered_tiles

func is_tile_visible_by_mycelium(tile: TileObject):
	return tile.get_discovered()

## alternative to try, would return array of tiles rather then dict[coords] = tile
#func get_all_tiles_visible_by_mycelium_filter():
	#var all_tiles = get_all_tiles() # Assuming this returns a dictionary
	#return all_tiles.values().filter(func(tile):
		#return tile.get_discovered()
	#)

# Shoot do we need to pass building_id, to get its size ?
# Or just show buildable places
func get_all_tiles_where_can_build():
	paths_computer.update_paths()
	# TODO: do the sorting here for now
	# should I keep track when adding new mycelium, or just compute every time its requested
	var buildable_tiles = []
	for coords in get_all_tiles():

		# TODO: Boran, how to show where can build 3x3 and other sizes buildings
		# Look for shape in coords, that match query.
		#var tile = get_tile_at(coords) as TileObject
		#var objects = tile.get_objects()
		if can_grow_structure_at_coords(BuildingObject.StructureType.Storage_Energy, coords):
			buildable_tiles.append(coords)
	return buildable_tiles

# TODO: add costs check, allow only to go below 0 to -10
# how to get radius
func can_afford_growth_cost(growth_cost: Dictionary) -> bool:
	# Check if the cost can be covered by the resources in _tally and _storage_tally
	for resource_type in growth_cost.keys():
		var required_amount = growth_cost[resource_type]
		var available_in_tally = get_tally(resource_type)
		var available_in_storage = level_data._storage_tally.get(resource_type,0)[0]  # Assuming this function returns the total storage available for a resource type

		# Total available resources is the sum from the mycelium network and storage structures
		var total_available = available_in_tally + available_in_storage

		if total_available < required_amount:
			# If any required resource is not available in sufficient amount, cannot afford the growth cost
			return false

	# If all costs can be covered, return True
	return true

func can_grow_structure_at_coords(building_id: BuildingObject.StructureType, coords: Vector2i):
	# TODO: need to check if there are ruins there
	if building_id == -1:
		return false
	if coords in get_base_coords():
		return false
	var building_size = BuildingObject.size[building_id]

	# if passing building object we could use get_tile_coords
	for x in range(building_size.x):
		for y in range(building_size.y):
			if not connected_to_base(coords + Vector2i(x, y)):
				return false

			var tile: = get_tile_at(coords + Vector2i(x, y))
			var overground = tile.get_overground()
			var mycelium = tile.get_mycelium()
			if overground != null:
				var type = overground.get_type()
				if type == ModelObject.Type.Plant:
					return true
					pass
				# allow for growing on top of plants,
				# but prune them
				# and collect carbon ?
				# for now just remove the plant, and grow structure instead.
				return false
			elif mycelium != null and mycelium.get_type() != ModelObject.Type.Mycelium:
				return false
	return true

func add_object_guarded(object: ModelObject) ->bool:
	if can_add_object(object):
		add_object(object)
		return true
	return false

func can_add_object(object: ModelObject):
	var tile = get_tile_at(object.get_coords())
	# TODO: is layer empty.
	# what about all
	var all_coords = object.get_tile_coords()
	var coords = object.get_coords()
	var val = true
	match object.get_type():
		ModelObject.Type.Mycelium, ModelObject.Type.MyceliumQueue, ModelObject.Type.MyceliumGrowing:
			val = val and tile.get_mycelium() == null
		ModelObject.Type.Plant:
			# overground can only have one type there ?
			# if using layer[overground] not null, then cannot build
			# if layer[mycelium] not null, plant can grow just on the ground
			# if layer[ground], something
			# if layer[ground] == blocked ?
			# have ruins under
			val = val and is_type_at_coords(coords, ModelObject.Type.Mycelium)
			val = val and not coords in get_base_coords()
			val = val and not is_ruin_at_coords(coords)
			val = val and tile.get_structure() == null
		ModelObject.Type.Harvester:
			val = val and tile.get_harvester() == null
			# is this general rule ? no two mycelium, no two buildings, no two plants ?
		ModelObject.Type.Creature: # this is movable, need to add add_movable_guarded.
			# all 3 below are over ground
			val = val and tile.get_ruin() == null
			val = val and tile.get_structure() == null
			val = val and not coords in get_base_coords()
		_:
			val = true
	return val

# TODO: add remove_object_layered, or remove_object_guarded
# which would remove mycelium and harvester
# remove_object will be for loaders and unloaders ? more direct
# for brute force removals
func remove_object_guarded(object: ModelObject):
	pass

# TODO: remove. will not need with layers

# or return dictionary[type] = Object # could this be our tile_layer[type]=object
# or tile_object[INDEX_TYPE], nah then how to add at index ? and check at index ?
func get_objects_types_at(coords: Vector2i):
	var list:Array = []
	for object in get_objects_at(coords):
		list.append(object.get_type())
	return list

func is_type_at_coords(coords: Vector2i, type):
	return get_tile_at(coords).has_object_type(type)

func is_ruin_at_coords(coords: Vector2i):
	return is_type_at_coords(coords, ModelObject.Type.Ruin)

func grow_structure_at_coords(building_id: BuildingObject.StructureType, coords: Vector2i, radius: int):
	var building_size = BuildingObject.size[building_id]

	if can_grow_structure_at_coords(building_id, coords):

		var tile: = get_tile_at(coords)
		var overground = tile.get_overground()
		# Check for plants under
		if overground != null:
			var type = overground.get_type()
			if type == ModelObject.Type.Plant:
				remove_object(overground)
		# TODO: keep track of buildings.
		# storage buildings, to keep eye on tally
		var building_category = BuildingObject.get_building_category(building_id)

		var building: BuildingObject = BuildingObject.new(coords, building_size, building_id, 100, radius)

		building.state_changed.connect(_building_state_changed)
		if building_category == BuildingObject.StructureCategory.Storage:
			# level_data.
			var resource_type = building.get_resource_stored_type()
			if not level_data._storage_structures.has(resource_type):
				level_data._storage_structures[resource_type] = {}
			level_data._storage_structures[resource_type][coords] = building
		# Otherwise first change is not pickeup
		# Resource does not have _ready
		# we could call it here actually
		building._ready()
		# instead of
		#building.set_state(BuildingObject.BuildingState.Building)
		add_object(building)

		return true

	return false

func spawn_resource_ball_at(coords: Vector2i, resource_type: ResourceObject.ResourceType, amount) -> void:
	add_movable(ResourceBallObject.new(coords, resource_type, amount))

func set_connected(coords: Vector2i, connection_coords: Vector2i, object: ModelObject, _connected_to_base: bool) -> void:
	level_data.set_connected(coords, connection_coords, object, _connected_to_base)

func get_all_movables() -> Dictionary:
	return level_data.get_all_movables()

func is_movable_at_coord(coord: Vector2i) -> bool:
	var all = get_all_movables()
	for movable in all.keys():
		if movable.get_coords() == coord:
			return true
	return false

func get_movable_at_coords(coords: Vector2i) -> MovableObject:
	var all = get_all_movables()
	for movable in all.keys():
		if movable.get_coords() == coords:
			return movable
	return null

# File saving, loading,

func load_default_hints():
	# Assuming you have a JSON file with default hints
	var file_path = "res://Data/Hints/hints.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		level_data.hints = JSON.parse_string(json_text) # Returns null if parsing failed.
		file.close()

# only hints now
func load_user_preferences():
	#var user_prefs_path = OS.get_user_data_dir() + "/user_hints_prefs.json"
	var user_prefs_path = "user://user_hints_prefs.json"
	if FileAccess.file_exists(user_prefs_path):
		var file = FileAccess.open(user_prefs_path, FileAccess.READ)
		if file:
			var user_prefs = JSON.parse_string(file.get_as_text())
			for hint_key in user_prefs.keys():
				if hint_key in level_data.hints:
					level_data.hints[hint_key]["show_again"] = user_prefs[hint_key]["show_again"]
			file.close()

# only hints now
func save_user_preferences():
	var user_prefs = {}
	for hint_key in level_data.hints.keys():
		user_prefs[hint_key] = {"show_again": level_data.hints[hint_key]["show_again"]}

	#var user_prefs_path = OS.get_user_data_dir() + "/user_hints_prefs.json"
	var user_prefs_path = "user://user_hints_prefs.json"
	var file = FileAccess.open(user_prefs_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(user_prefs))
		file.close()

# only hints now
func reset_user_preferences():
	#var user_prefs_path = OS.get_user_data_dir() + "/user_hints_prefs.json"
	var user_prefs_path = "user://user_hints_prefs.json"
	if FileAccess.file_exists(user_prefs_path):
		OS.move_to_trash(ProjectSettings.globalize_path(user_prefs_path))
	load_default_hints()
	# Optionally, reload user preferences if not just resetting to defaults
	# load_user_preferences()

func on_do_not_show_again_hint_toggled(hint_key: String, is_toggled: bool):
	if hint_key in level_data.hints:
		level_data.hints[hint_key].show_again = !is_toggled
		save_user_preferences()

func set_buildable(buildable: Dictionary):
	level_data.set_buildable(buildable)

func get_buildable() -> Dictionary:
	return level_data.get_buildable()

### Process
var count: float
func _process(delta: float):
	if count > 1.0:
		count = 0
	count += delta
