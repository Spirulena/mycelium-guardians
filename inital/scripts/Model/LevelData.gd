class_name LevelData extends Resource

enum ProductionTypes {SmogExtracted, AcidProduced, SporesProduced}

var _tally: Dictionary
var _storage_tally: Dictionary
var _tile_at_coords: Dictionary
# In Path Computer, use different source of seed of colony
# That way we can have baseless, and split colony
var _base_coords: Array[Vector2i] # Or should it be just 1st, and calculate get_tile_coords(size) like with buildings
var _production_amounts: Dictionary
var _movables: Dictionary
var _wind: Dictionary
var _mycelium_expansion_cost: Dictionary
var _resource_noise_map: Dictionary
var _env_noise: Dictionary
var _all_mycelium: Dictionary
var _discovered_tiles_coords: Dictionary # TODO: this could speed up, maybe; Living here as a note
var _grown_mycelium: Dictionary
# Maybe can use same functions and dict: NoiseEnum {coord: value}
var _water_level_noise: Dictionary
var _radiation_level_noise: Dictionary
var _smog_level_noise: Dictionary
var _water_level_extraction: Dictionary
var _harvesters: Harvester
var _enzymes_amount: float
class Harvester:
	var default_extraction_factor: float

class Enzymes:
	var last_environmental_bonus: float
	var last_water_bonus: float
	var production_bonus_due_to_water: float
	var last_energy_input: float
	var production_percent: float
	var last_enzyme_output: float
	var efficiency: float
var _enzymes: Enzymes

var hints: Dictionary # this can move to game_data

signal model_changed(event: Dictionary)

var _storage_structures: Dictionary
var _ignore_water_noise: bool
var _buildable: Dictionary

var _config: Dictionary

func set_buildable(buildable: Dictionary):
	_buildable = buildable

func get_buildable() -> Dictionary:
	return _buildable.duplicate()

func _init():
	_config = {
		'smog_use_level_editor': false,
		'radiation_use_level_editor': false,
	}
	_buildable = {
		BuildingObject.StructureCategory.Absorber: [BuildingObject.StructureType.Absorber_Smog],
	}
	_ignore_water_noise = true
	hints = {}
	_enzymes_amount = 0.0
	_harvesters = Harvester.new()
	_harvesters.default_extraction_factor = 0.4
	_water_level_noise = {}
	_radiation_level_noise = {}
	_smog_level_noise = {}
	_water_level_extraction = {}
	_all_mycelium = {}
	_grown_mycelium = {}
	_mycelium_expansion_cost = {
		ResourceObject.ResourceType.Water: 0.05,  # From 0.05
		ResourceObject.ResourceType.Energy: 0.01,  # From 0.01
		ResourceObject.ResourceType.Minerals: 0.05,  # From 0.05
		ResourceObject.ResourceType.Carbon: 0.05,  # From 0.05
		ResourceObject.ResourceType.Acid: 0.0,
		ResourceObject.ResourceType.Enzymes: 0.0,
	}
	# Try this
	#_mycelium_expansion_cost2 = {
		#ResourceObject.ResourceType.Water: 0.5,  # From 0.05
		#ResourceObject.ResourceType.Energy: 0.5,  # From 0.01
		#ResourceObject.ResourceType.Minerals: 0.1,  # From 0.05
		#ResourceObject.ResourceType.Carbon: 0.5,  # From 0.05
		#ResourceObject.ResourceType.Acid: 0.0,
		#ResourceObject.ResourceType.Enzymes: 0.0,
	#}
	_wind = {
		'speed': 10.0,
		'direction': Vector2(1, -1),
		'vector': Vector2(randf_range(-.01, .01), randf_range(-.01, .01)),
	}
	_tally = {}
	_storage_structures = {}
	_storage_structures = {
		ResourceObject.ResourceType.Water: {},
		ResourceObject.ResourceType.Energy: {},
		ResourceObject.ResourceType.Minerals: {},
		ResourceObject.ResourceType.Carbon: {},
		ResourceObject.ResourceType.Acid: {},
		ResourceObject.ResourceType.Enzymes: {},
	}
	_storage_tally = {}
	_tile_at_coords = {}
	_base_coords = [Vector2i(0, 0), Vector2i(0, -1),
	Vector2i(0,-2), Vector2i(-1,-2), Vector2i(-2,-2), Vector2i(-2,-1), Vector2i(-1,-1),
	Vector2i(-2,0), Vector2i(-1,0),
	]
	# enum {STATE, MAX, HARD_CAP}
	_tally[ResourceObject.ResourceType.Water] = [100, 100]
	_tally[ResourceObject.ResourceType.Energy] = [100, 100]
	_tally[ResourceObject.ResourceType.Minerals] = [100, 100]
	_tally[ResourceObject.ResourceType.Carbon] = [100, 100]
	_tally[ResourceObject.ResourceType.Acid] = [100, 100]
	_tally[ResourceObject.ResourceType.Enzymes] = [50, 100]

	_storage_tally[ResourceObject.ResourceType.Water] = [0, 0]
	_storage_tally[ResourceObject.ResourceType.Energy] = [0, 0]
	_storage_tally[ResourceObject.ResourceType.Minerals] = [0, 0]
	_storage_tally[ResourceObject.ResourceType.Carbon] = [0, 0]
	_storage_tally[ResourceObject.ResourceType.Acid] = [0, 0]
	_storage_tally[ResourceObject.ResourceType.Enzymes] = [0, 0]

	# Enzymes, change to resource object, class_name ?
	_enzymes = Enzymes.new()
	_enzymes.set("last_environmental_bonus", 12)
	#_enzymes.last_environmental_bonus = 0
	_enzymes.last_water_bonus = 0
	_enzymes.production_bonus_due_to_water = 0
	_enzymes.last_energy_input = 0
	_enzymes.production_percent = 50
	_enzymes.last_enzyme_output = 0
	_enzymes.efficiency = 0
	_production_amounts = {
		ProductionTypes.SmogExtracted: 0,
		ProductionTypes.AcidProduced: 0,
		ProductionTypes.SporesProduced: 0,
	}
	_resource_noise_map = {
		# TODO: use one seed for the level or world(?)
		ResourceObject.ResourceType.Water: { 'noise': FastNoiseLite.new(), 'seed': 111 },
		ResourceObject.ResourceType.Minerals: { 'noise': FastNoiseLite.new(), 'seed': 222 },
		ResourceObject.ResourceType.Carbon: { 'noise': FastNoiseLite.new(), 'seed': 333 },
	}
	for type in _resource_noise_map.keys():
		_resource_noise_map[type]['noise'].noise_type = FastNoiseLite.TYPE_SIMPLEX
		_resource_noise_map[type]['noise'].frequency = 0.1
		_resource_noise_map[type]['noise'].seed = _resource_noise_map[type]['seed']
	# TODO: move water here,
	_env_noise = {
		'Radiation': {'noise': FastNoiseLite.new(), 'seed': 123123},
		'Smog': {'noise': FastNoiseLite.new(), 'seed': 234234},
	}
	for noise_type in _env_noise.keys():
		_env_noise[noise_type]['noise'].noise_type = FastNoiseLite.TYPE_SIMPLEX
		_env_noise[noise_type]['noise'].frequency = 0.04
		_env_noise[noise_type]['noise'].seed = _env_noise[noise_type]['seed']
	_movables = {}

	#_enzymes.set("last_environmental_bonus", 12)
	##_enzymes.last_environmental_bonus = 0
	#_enzymes.last_water_bonus = 0
	#_enzymes.last_energy_input = 0
	#_enzymes.production_percent = 50
	#_enzymes.last_enzyme_output = 0
	#_enzymes.efficiency = 0

func set_ignore_water_noise(val: bool):
	_ignore_water_noise = val

func set_config(key, val):
	if _config.get(key) != null:
		_config[key] = val
	# Return ? null or value ?

func get_config(key):
	return _config.get(key)

func update_seed(seed: int):
	for type in _resource_noise_map.keys():
		_resource_noise_map[type]['noise'].seed = seed

	for noise_type in _env_noise.keys():
		_env_noise[noise_type]['noise'].seed = seed

func get_enzymes(key):
	return _enzymes.get(key)

func set_enzymes(key, value):
	_enzymes.set(key, value)
	# emit change
	var prev = get_enzymes(key)
	if value != prev:
		_enzymes.set(key, value)
		var change: Dictionary = {
			'curr': value,
			'prev': prev,
			'prop': key,
			'type': 'enzymes',
		}
		model_changed.emit(change)
		return true
	return false

func change_enzymes(key, value):
	set_enzymes(key, get_enzymes(key) + value)

func get_enzymes_amount() -> float:
	return get_tally(ResourceObject.ResourceType.Enzymes)
	#return _enzymes_amount

func set_enzymes_amount(amount: float) -> bool:
	var prev = get_enzymes_amount()
	if amount != prev:
		_enzymes_amount = amount
		var change: Dictionary = {
			'curr': amount,
			'prev': prev,
			'type': 'enzymes_amount',
		}
		model_changed.emit(change)
		set_tally(ResourceObject.ResourceType.Enzymes, amount)
		return true
	return false

func change_enzymes_amount(amount: float) -> bool:
	return set_enzymes_amount(get_enzymes_amount() + amount)

func get_smog_level_noise_at(coords: Vector2i):
	if not _smog_level_noise.has(coords):
		# or use 1-100 ?
		_smog_level_noise[coords] = clampf(_env_noise['Smog']['noise'].get_noise_2dv(coords), 0, 1.0)
	return _smog_level_noise[coords]

func get_smog_scaled(coords: Vector2i) -> int:
	# Replace with getting the level from LevelEditor
	# SMOG_LEVEL_EDITOR
	if get_radiation_level_noise_at(coords) < 0.3:
		return 0
	else:
		return 1

func get_radiation_scaled(coords: Vector2i) -> int:
	if get_radiation_level_noise_at(coords) < 0.3:
		return 0
	else:
		return 1

func get_radiation_level_noise_at(coords: Vector2i):
	if not _radiation_level_noise.has(coords):
		# or use 1-100 ?
		_radiation_level_noise[coords] = clampf(_env_noise['Radiation']['noise'].get_noise_2dv(coords), 0, 1.0)
	return _radiation_level_noise[coords]

func get_water_level_noise_at(coords: Vector2i):
	if not _water_level_noise.has(coords):
		_water_level_noise[coords] = clampf(_resource_noise_map[ResourceObject.ResourceType.Water]['noise'].get_noise_2dv(coords), 0, 1.0)
	return _water_level_noise[coords]

func get_water_level(coords: Vector2i) -> float:
	if _ignore_water_noise:
		return 0
	var base_water_level = get_water_level_noise_at(coords)
	var extracted_amount = _water_level_extraction.get(coords, 0)
	var distributed_amount = calculate_distributed_water_at(coords)

	return base_water_level - extracted_amount + distributed_amount

func calculate_distributed_water_at(coords: Vector2i):
	return 0

func tile_changed(change: Dictionary):
	model_changed.emit(change)

func get_mycelium_expansion_cost():
	return _mycelium_expansion_cost

# Could just do get_wind('direction')
func get_wind_direction():
	return _wind['direction']

func get_wind_speed():
	return _wind.get('speed')

func get_wind_vector():
	return _wind.get('vector')

func set_wind_vector(value):
	# TODO: emit model change
	# todo set global
	_wind['vector'] = value

func set_wind_direction(value):
	# TODO: emit model change
	_wind['direction'] = value
	RenderingServer.global_shader_parameter_set('wind_direction', value * 0.1)

func add_resource(resource: ResourceObject):
	get_tile_at(resource.get_coords()).add_resource(resource)

func get_resource_at(coords: Vector2i):
	return get_tile_at(coords).get_resource()

func get_noise_resource_amount_at(type, coords: Vector2i):
	return clampf(_resource_noise_map[type]['noise'].get_noise_2dv(coords), 0, 1.0) * 1000

func get_noise_resource_type_at(coords: Vector2i):
	var return_type = null
	for type in _resource_noise_map.keys():
		if get_noise_resource_amount_at(type, coords) > 500:
			return_type = type
			return return_type
	return return_type

# this is resource amount, global resource
func get_tally(type: ResourceObject.ResourceType):
	return _tally[type][0]

func change_tally(type: ResourceObject.ResourceType, amount):
	set_tally(type, get_tally(type) + amount)

func set_tally(type: ResourceObject.ResourceType, value):
	var limit = get_tally_storage_limit(type)
	if value > limit:
		# track overproduction ?
		# will decrease health as well
		value = limit
		# that is causing to drain minerals in radiation absorber
	# Will we cap, or rather track deficit
	var prev = get_tally(type)
	if prev != value:
		model_changed.emit({
			'type': 'Resource',
			'resource': type,
			'coords': null,
			'prev': prev,
			'curr': value,
		})
		_tally[type][0] = value

func get_tally_storage_limit(type: ResourceObject.ResourceType):
	return _tally[type][1]

func set_tally_storage_limit(type: ResourceObject.ResourceType, value, model_object: ModelObject):
	# TODO: clamp
	var prev = get_tally_storage_limit(type)
	model_changed.emit({
		'type': 'ResourceLimit',
		'resource_type': type,
		'object': model_object,
		'coords': model_object.get_coords(),
		'prev': prev,
		'curr': value,
		'change_amount': value - prev,
	})
	_tally[type][1] = value

func change_tally_storage_limit(type: ResourceObject.ResourceType, amount, model_object: ModelObject):
	set_tally_storage_limit(type, get_tally_storage_limit(type) + amount, model_object)

func get_extraction_rate_at_coords(coords:Vector2i):
	return 1.0 * _harvesters.default_extraction_factor # ? * factor of 0.1 ?

func get_production_amount(key: ProductionTypes):
	return _production_amounts.get(key, 0)

func get_base_coords() -> Array[Vector2i]:
	return _base_coords

func get_all_tiles():
	return _tile_at_coords

func get_tile_at(coords: Vector2i) -> TileObject:
	if not _tile_at_coords.has(coords):
		_tile_at_coords[coords] = TileObject.new(coords)
		_tile_at_coords[coords].tile_changed.connect(tile_changed)
		model_changed.emit({
			'type': 'TileObject',
			'coords': coords,
			'prev': null,
			'curr': _tile_at_coords[coords],
		})
	return _tile_at_coords[coords]

func add_movable(object: ModelObject):
	# TODO change. _movales[coords]? or have a cache of that ?
	_movables[object] = true

	model_changed.emit({
		'type': object.get_type(),
		'coords': object.get_coords(),
		'prev': null,
		'curr': object,
	})

func remove_movable(object: MovableObject):
	_movables.erase(object)

	object.set_state(ModelObject.State.Removed)

	model_changed.emit({
		'type': object.get_type(),
		'coords': object.get_coords(),
		'prev': object,
		'curr': null,
	})

func get_all_movables():
	return _movables

func all_mycelium_tiles_add(myc: MyceliumObject) -> bool:
	if _all_mycelium.has(myc.get_coords()):
		var coords = myc.get_coords()
		var tile = get_tile_at(coords)
		var tile_myc = tile.get_mycelium()
		var all_ref = _all_mycelium.get(coords)
		#print_stack()
		return false
	_all_mycelium[myc.get_coords()] = myc
	return true

func add_object(object: ModelObject):
	# Could move it to controller, model changed
	# Keep track of all mycelium
	if object.get_type() == ModelObject.Type.Mycelium:
		var ret = all_mycelium_tiles_add(object)
		if ret == false:
			print_stack()
			return
	for tile_coords in object.get_tile_coords():
		get_tile_at(tile_coords).add_object(object)

	model_changed.emit({
		'type': object.get_type(),
		'coords': object.get_coords(),
		'prev': null,
		'curr': object,
	})



func remove_object(object: ModelObject):
	if object == null:
		return false
	if object.get_type() == ModelObject.Type.Mycelium:
		for tile_coords in object.get_tile_coords():
			var harvester = get_tile_at(tile_coords).get_harvester()
			if harvester != null:
				remove_object(harvester)

	object.set_state(ModelObject.State.Removed)

	model_changed.emit({
		'type': object.get_type(),
		'coords': object.get_coords(),
		'prev': object,
		'curr': null,
	})
	for tile_coords in object.get_tile_coords():
		get_tile_at(tile_coords).remove_object(object)
	# Could move it to controller, model changed
	# Keep track of all mycelium
	if object.get_type() == ModelObject.Type.Mycelium:
		all_mycelium_remove(object)
		_grown_mycelium.erase(object.get_coords())

func all_mycelium_remove(object: MyceliumObject):
	var ret:bool = _all_mycelium.erase(object.get_coords())
	if ret == false:
		print_debug("trying to erase non existing mycelium from _all_mycelium")
		print_stack()
	return ret

func get_all_mycelium() -> Dictionary:
	return _all_mycelium

func get_objects_at(coords: Vector2i):
	return get_tile_at(coords).get_objects()

func get_mycelium_at(coords: Vector2i):
	return get_tile_at(coords).get_mycelium()

func get_ambient_smog_production_at(coords: Vector2i):
	return 100

func get_ambient_radiation_production_at(coords: Vector2i):
	return 100

func get_acid_rate():
	return 1

func set_connected(coords: Vector2i, connection_coords: Vector2i, object: ModelObject, _connected_to_base: bool):
	var tile = get_tile_at(coords)
	var objects = tile.get_objects()
	if object in objects:
		#print("got object: ", object, " in ", objects)
		#coords, connection_coords, object, is_connected
		var prev = object._connected_to_base
		object._connected_to_base = _connected_to_base
		object._connection_coords = connection_coords
		model_changed.emit({
			'type': 'ConnectionToBase',
			'object': object,
			'coords': object.get_coords(),
			# this is usually used to indicate add, remove
			# what about indicating what is changed inside the object ?
			'prev': prev,
			'curr': _connected_to_base,
		})
