extends Resource
class_name TileObject
## Holds Tile Data

var _coords: Vector2i
var _objects: Array[ModelObject]
var _radiation: int
var _resources: Dictionary
var _smog: float
var _chances: Dictionary ## Cut ?
var _smog_presenter: SmogTilePresenter
var _discovered: bool
var _desired_resource_levels: Dictionary
# ??
enum TileLayer { Sky=0, Overground, Mycelium, Harvester, Resource }
var object_to_layer_map: Dictionary

signal tile_changed(change: Dictionary)
signal tile_changed_direct(change: Dictionary)

func has_object_type(object_type: String):
	return _objects[object_to_layer_map[object_type]] != null

func _init(coords):
	object_to_layer_map = {
		ModelObject.Type.AIPanel: TileLayer.Overground,
		ModelObject.Type.Building: TileLayer.Overground,
		ModelObject.Type.Ruin: TileLayer.Overground,
		ModelObject.Type.Plant: TileLayer.Overground,
		ModelObject.Type.Harvester: TileLayer.Harvester,
		ModelObject.Type.Mycelium: TileLayer.Mycelium,
		ModelObject.Type.MyceliumQueue: TileLayer.Mycelium, # Move to MyceliumQueue ?
		ModelObject.Type.MyceliumGrowing: TileLayer.Mycelium,
		ModelObject.Type.Resource: TileLayer.Resource,
		#ModelObject.Type.Enzyme: "enzyme", # part of mycelium ?
		#ModelObject.Type.Creature: "creature", # Movable
		#ModelObject.Type.ResourceBall: "resource_ball" # Movable
	}
	_coords = coords
	_objects = []# fill
	_objects.resize(5)
	_objects.fill(null)
	_radiation = 0 # get from noise ?, or rather level_controller.get_noise
	# it inside will have noise + static level radiation.
	# Probably should set it after tile is added.

	# here so plants can use it
	_resources = {
		ResourceObject.ResourceType.Water: 0,
		ResourceObject.ResourceType.Minerals: 0,
		ResourceObject.ResourceType.Energy: 0, # so we can get it
		ResourceObject.ResourceType.Carbon: 0,
		ResourceObject.ResourceType.Enzymes: 0,
	}
	_desired_resource_levels = {
		ResourceObject.ResourceType.Water: 0,
		ResourceObject.ResourceType.Minerals: 0,
		ResourceObject.ResourceType.Energy: 0, # so we can get it
		ResourceObject.ResourceType.Carbon: 0,
		ResourceObject.ResourceType.Enzymes: 0,
	}
	_smog = 0
	_chances = {
		'worm': 0.0,
		'plants': 0.0,
	}
	_smog_presenter = null
	_discovered = false
	var _mycelium_depth: float = 0
	var _mycelium_thickness: float = 0

func get_water_level():
	return get_resource_level(ResourceObject.ResourceType.Water)

func get_minerals():
	return get_resource_level(ResourceObject.ResourceType.Minerals)

func get_resource_level(resource_type: ResourceObject.ResourceType) -> float:
	return _resources[resource_type]

func get_tally(resource_type: ResourceObject.ResourceType) -> float:
	return get_resource_level(resource_type)

func change_tally(resource_type: ResourceObject.ResourceType, amount_to_add: float) -> bool:
	return set_tally(resource_type, get_resource_level(resource_type) + amount_to_add)

var storage_limit_per_type: Dictionary = {
		ResourceObject.ResourceType.Water: 0.2,
		ResourceObject.ResourceType.Minerals: 0.1,
		ResourceObject.ResourceType.Energy: 0.1,
		ResourceObject.ResourceType.Carbon: 0.1,
		ResourceObject.ResourceType.Enzymes: 0.1,
	}

func get_max_tile_storage(resource_type: ResourceObject.ResourceType):
	return storage_limit_per_type.get(resource_type, 1.0) # get it from mycelium + soil parameters,


func set_tally(resource_type: ResourceObject.ResourceType, amount: float) -> bool:
	var prev: float = get_resource_level(resource_type)
	#var diff: float = amount - prev
	if prev != amount:
		_resources[resource_type] = amount
		# emit change
		tile_changed.emit({
			'type': 'tile_resource',
			'resource_type': resource_type,
			'coords': _coords,
			'tile': self,
			'prev': prev,
			'curr': amount,
		})
		return true
	return false

func can_consume_resources(water_needed: float, minerals_needed: float) -> bool:
	var current_water_level = get_water_level()
	var current_minerals_level = get_minerals()
	return current_water_level >= water_needed and current_minerals_level >= minerals_needed

func consume_resources(water_to_consume: float, minerals_to_consume: float) -> bool:
	if can_consume_resources(water_to_consume, minerals_to_consume):
		change_tally(ResourceObject.ResourceType.Water, -water_to_consume)
		change_tally(ResourceObject.ResourceType.Minerals, -minerals_to_consume)
		return true
	return false

func can_receive_resources():
	return self.is_mycelium()

# is grown mycelium
func is_mycelium() -> bool:
	return get_mycelium() != null and get_mycelium().get_type() == ModelObject.Type.Mycelium

# func getter with get('property_name')
func get_discovered() -> bool:
	return _discovered

func set_discovered(val: bool):
	var prev = _discovered
	var curr = val

	_discovered = val

	if prev != curr:
		var change = {
			'type': 'discovered',
			'coords': _coords,
			'tile': self,
			'prev': prev,
			'curr': curr,
		}
		tile_changed.emit(change)
		tile_changed_direct.emit(change)
		return true # Changed
	return false # Not changed

# discovered in radius ?
func set_discovered_in_radius(val: bool, radius: int):
	var coords = LevelController.get_level_controller().get_coords_in_radius(get_coords(), radius)
	for coord in coords:
		LevelController.get_level_controller().get_tile_at(coord).set_discovered(val)
	return true

func set_smog_presenter(presenter: SmogTilePresenter):
	_smog_presenter = presenter

func have_smog_presenter():
	return _smog_presenter != null

func model_changed(change: Dictionary):
	pass

# TODO : cut ?
func get_chance(key: String):
	return _chances.get(key)

func set_chance(key: String, value: float):
	var prev = get_chance(key)
	var curr = clampf(value, 0.0, 1.0)
	_chances[key] = curr
	if prev != curr:
		tile_changed.emit({
			'type': 'chance',
			'coords': _coords,
			'tile': self,
			'key': key,
			'prev': prev,
			'curr': curr,
		})
		return true # or dict from change ?
	return false

func change_chance(key: String, value: float):
	var prev = get_chance(key)
	var new_value = prev + value
	#print("Chance change: %s - old: %0.2f new: %0.2f, change: %0.2f" % [key, prev, new_value, value])
	return set_chance(key, new_value)

func add_object(object: ModelObject):

	_objects[object_to_layer_map[object.get_type()]] = object

	match object.get_type():
		ModelObject.Type.Resource:
			# For resource, connect the signal from resource_changed-> tile_changed
			object.resource_changed.connect(_on_resource_changed)
		ModelObject.Type.Harvester:
			object.set_resource(self.get_resource())
	# TODO: set resource
	tile_changed_direct.emit({
		'type': object.get_type(),
		'coords': object.get_coords(),
		'prev': null,
		'curr': object,
	})

# Change is emited from LevelDataLevel. so need to remove from level controller ?
func remove_object(object: ModelObject):
	tile_changed_direct.emit({
		'type': object.get_type(),
		'coords': object.get_coords(),
		'prev': object,
		'curr': null,
	})

	_objects[object_to_layer_map[object.get_type()]] = null
	pass

func _on_resource_changed(change: Dictionary):
	# FIXME: this have to go to model rather than tile changed
	# or add tile
	change['tile'] = self
	tile_changed.emit(change)

func get_coords():
	return _coords

func get_objects() -> Array[ModelObject]:
	return _objects

## This can return 3 different kinds, MyceliumQueue, mGrowing, MyceliumGrown
## Shall they inherit from Mycelium. Or just be One. And this should be different state.
func get_mycelium():
	return self._objects[TileLayer.Mycelium]

func get_harvester():
	return _objects[TileLayer.Harvester]

func get_resource():
	return _objects[TileLayer.Resource]

func get_overground():
	return _objects[TileLayer.Overground]

func get_plant() -> BuildingObject:
	var o = _objects[TileLayer.Overground]
	if o != null and o.get_type() == ModelObject.Type.Plant:
		return o
	else:
		return null

func get_structure() -> BuildingObject:
	var o = _objects[TileLayer.Overground]
	if o != null and o.get_type() == ModelObject.Type.Building:
		return o
	else:
		return null

func get_building_type():
	var structure: BuildingObject = get_structure()
	if structure:
		return structure.get_building_type()
	return BuildingObject.StructureType.Missing

func get_ruin(): #change with is type in overground a ruin and see what uses this one
	return _objects[TileLayer.Overground]

func get_type(model_type):
	var object = _objects[object_to_layer_map[model_type]]
	if object == null:
		return null
	if object.get_type() == model_type: # As it gets object in layer
		# In overground it can be few types there
		return object
	else:
		return null
	#return _objects[object_to_layer_map[model_type]]
	# this will return layer and not the type
	# for overground this needs additional stuff

func has_plant():
	var overground = get_overground()
	return overground != null and overground.get_type() == ModelObject.Type.Plant

func add_resource(resource: ResourceObject):
	add_object(resource)

func get_smog() -> float:
	return _smog

func set_smog(smog: float):
	var prev_smog = _smog
	if smog != prev_smog:
		_smog = smog
		tile_changed.emit({
			'type': 'smog',
			'coords': _coords,
			'tile': self,
			'prev': prev_smog,
			'curr': smog,
		})

func change_smog(amount: float):
	set_smog(get_smog() + amount)

func get_radiation():
	return _radiation

func set_radiation(radiation: int):
	var prev_radiation = _radiation
	if radiation != prev_radiation:
		_radiation = radiation
		tile_changed.emit({
			'type': 'radiation',
			'coords': _coords,
			'tile': self,
			'prev': prev_radiation,
			'curr': radiation,
		})

func change_radiation(amount: int):
	set_radiation(get_radiation() + amount)

func is_suitable_for_grass() -> bool:
	# Example condition: Enough water and minerals, and no existing grass
	return get_water_level() >= 3 and get_minerals() >= 1 and not has_plant()
