extends ModelObject
class_name BuildingObject

enum StructureCategory {
	Storage,
	Absorber,
	Emission,
}

enum StructureType {
	Missing = -1,
	Storage_Water,
	Storage_Energy,
	Storage_Minerals,
	Storage_Carbon,
	Export_Center,# just for now, will change to export flag
	Absorber_Radiation,
	Absorber_Smog,
	Emitter_Spore,
	History_Apartment_1,
	Techno_flat_panel,
	Base,
}

static var resource_output = {
	StructureType.Storage_Water: 0,
	StructureType.Storage_Energy: 1,
	StructureType.Storage_Minerals: 2,
	StructureType.Storage_Carbon: 3,
	StructureType.Absorber_Radiation: 1,
	StructureType.Absorber_Smog: 2,
	StructureType.Export_Center: 3,
}
static var type_to_category = {
	StructureType.Storage_Water : StructureCategory.Storage,
	StructureType.Storage_Energy : StructureCategory.Storage,
	StructureType.Storage_Minerals : StructureCategory.Storage,
	StructureType.Storage_Carbon : StructureCategory.Storage,
	StructureType.Absorber_Radiation : StructureCategory.Absorber,
	StructureType.Absorber_Smog : StructureCategory.Absorber,
	StructureType.Emitter_Spore : StructureCategory.Emission,
	StructureType.Export_Center : StructureCategory.Emission,
}

static var radiation_radius = {
	StructureType.Missing: 0,
	StructureType.Storage_Water: 0,
	StructureType.Storage_Energy: 0,
	StructureType.Storage_Minerals: 0,
	StructureType.Storage_Carbon: 0,
	StructureType.Absorber_Radiation: 4,
	StructureType.Absorber_Smog: 0,
	StructureType.Emitter_Spore: 0,
}

# smog_radius
static var smog_radius = {
	StructureType.Missing: 0,
	StructureType.Storage_Water: 0,
	StructureType.Storage_Energy: 0,
	StructureType.Storage_Minerals: 0,
	StructureType.Storage_Carbon: 0,
	StructureType.Absorber_Radiation: 0,
	StructureType.Absorber_Smog: 5,
	StructureType.Emitter_Spore: 0,
}

static func get_radiation_radius_for_type(building_id):
	return radiation_radius.get(building_id, 0)

static func get_smog_radius_for_type(building_id):
	return smog_radius.get(building_id, 0)

static func get_radius_for(building_id):
	match building_id:
		BuildingObject.StructureType.Absorber_Smog:
			return get_smog_radius_for_type(building_id)
		BuildingObject.StructureType.Absorber_Radiation:
			return get_radiation_radius_for_type(building_id)
		# for below show maximum radius
		BuildingObject.StructureType.Export_Center:
			return 5 # store it somehow in data, json, custom resource
		BuildingObject.StructureType.Storage_Water:
			return 5
		BuildingObject.StructureType.Storage_Energy:
			return 5
		BuildingObject.StructureType.Storage_Minerals:
			return 5
		BuildingObject.StructureType.Storage_Carbon:
			return 5
		_:
			return 0

# TODO, add export center radius ?, storage. they are both dynamic

func get_radius():
	match _building_type:
		BuildingObject.StructureType.Absorber_Smog:
			return self.radius
		BuildingObject.StructureType.Absorber_Radiation:
			return self.radius
		BuildingObject.StructureType.Export_Center:
			return self.radius
		BuildingObject.StructureType.Storage_Water:
			return self.radius
		BuildingObject.StructureType.Storage_Energy:
			return self.radius
		BuildingObject.StructureType.Storage_Minerals:
			return self.radius
		BuildingObject.StructureType.Storage_Carbon:
			return self.radius
		_:
			return 0

# TODO: get_radius_coords() -> Array[Vector2i]
# so we can have predefined paterns of coords with diff shapes

static var building_size = {
	StructureType.Missing: Vector2i(1, 1),
	StructureType.Storage_Water: Vector2i(1, 1),
	StructureType.Storage_Energy: Vector2i(1, 1),
	StructureType.Storage_Minerals: Vector2i(1, 1),
	StructureType.Storage_Carbon: Vector2i(1, 1),
	StructureType.Absorber_Radiation: Vector2i(1, 1),
	StructureType.Absorber_Smog: Vector2i(1, 1),
	StructureType.Emitter_Spore: Vector2i(3, 3),
	StructureType.Export_Center: Vector2i(1, 1),
}

# This just a name
# the dict shoudl be just another file on disk for another structure.

static var names = {
	StructureType.Missing: "Structure placeholder",
	StructureType.Storage_Water: "Water",
	StructureType.Storage_Energy: "Energy",
	StructureType.Storage_Minerals: "Minerals",
	StructureType.Storage_Carbon: "Carbon",
	StructureType.Absorber_Radiation: "Radiation",
	StructureType.Absorber_Smog: "Smog",
	StructureType.Emitter_Spore: "Spore Tower",
	StructureType.Export_Center: "Exchange Hub",
}

static var category_names: Dictionary = {
	StructureCategory.Storage: "Storage Collector",
	StructureCategory.Absorber: "Absorber",
	StructureCategory.Emission: "Dispersal & Trade",
}

static var tool_tips = {
	StructureType.Missing: "Building name placeholder",
	StructureType.Storage_Water: "A specialized sclerotium for water accumulation and storage, enhancing drought resilience.",
	StructureType.Storage_Energy: "Stores surplus energy harvested by phototrophic and radiotrophic structures for later use.",
	StructureType.Storage_Minerals: "Gathers and preserves minerals extracted from the environment, serving as a nutrient reservoir.",
	StructureType.Storage_Carbon: "Secures carbon assimilated from the atmosphere or decomposed matter, crucial for building fungal biomass.",
	StructureType.Absorber_Radiation: "Utilizes radiotrophic fungi's ability to convert radiation into chemical energy, powering mycelial networks.",
	StructureType.Absorber_Smog: "Employs smog-filtering fungi to cleanse air pollutants and repurpose them into useful minerals.",
	StructureType.Emitter_Spore: "Elevated nodes that release spores into the atmosphere, potentially influencing local weather patterns.",
	StructureType.Export_Center: "Facilitates resource sharing with surrounding ecosystems and allows for the import of essential nutrients like carbon.",
}

static var spawn_offset = {
	StructureType.Missing: Vector2(0, -200),
	StructureType.Storage_Water:  Vector2(0, -200),
	StructureType.Storage_Energy:  Vector2(0, -200),
	StructureType.Storage_Minerals:  Vector2(0, -200),
	StructureType.Storage_Carbon:  Vector2(0, -200),
	StructureType.Absorber_Radiation:  Vector2(0, -50),
	StructureType.Absorber_Smog: Vector2(0, -364),
	StructureType.Emitter_Spore:  Vector2(0, -350),
	StructureType.Export_Center:  Vector2(0, -200),
	StructureType.History_Apartment_1: Vector2(0, 200),
	StructureType.Techno_flat_panel: Vector2(0, -50),
}

## Which buildings can be placed, displayed in menu
static var buildable: Dictionary = {
	StructureCategory.Absorber: [StructureType.Absorber_Smog],
}

static var growth_cost: Dictionary = {
	StructureType.Missing: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 1.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 1.0,
	},
	StructureType.Storage_Water: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 1.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 3.0,
	},
	StructureType.Storage_Energy: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 1.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 3.0,
	},
	StructureType.Storage_Minerals: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 1.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 3.0,
	},
	StructureType.Storage_Carbon: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 1.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 3.0,
	},
	StructureType.Absorber_Radiation: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 1.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 5.0,
	},
	StructureType.Absorber_Smog: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 1.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 5.0,
	},
	StructureType.Emitter_Spore: {
		GameTypes.ResourceType.Water: 5.0,
		GameTypes.ResourceType.Energy: 5.0,
		GameTypes.ResourceType.Minerals: 5.0,
		GameTypes.ResourceType.Carbon: 5.0,
	},
	StructureType.Export_Center: {
		GameTypes.ResourceType.Water: 1.0,
		GameTypes.ResourceType.Energy: 2.0,
		GameTypes.ResourceType.Minerals: 1.0,
		GameTypes.ResourceType.Carbon: 2.0,
	},
}

var _building_type: StructureType
var _building_category : StructureCategory
var _storage
var _resource_storage_type: GameTypes.ResourceType

static var BuildingState = {
	"Preview": "preview",
	"Building" : "building",# Growing
	"Done": "done",# Grown, Active ?
	"Build": "build",
	"Upgrading": "upgrading",
}

signal building_changed(change)# this is not used anywhere

var _resource
var _harvester
var _growth# what is that ?

# for now ignore that, i do not want to add another setter
#class Sclerotia:
	#var max_radius: int
	#var min_radius: int
	#var radius: int
	#var collection_radius: int
	#var collection_rate: float
#var _sclerotia: Sclerotia

var max_radius: int
var min_radius: int
var radius: int

var collection_rate: float

# GENES

var mutation: bool = false
var mutation_id: String

var mutation_decay_time_factor: float = 1.0
var mutation_smog_change_factor: float = 1.0
var mutation_growth_speed_factor: float = 1.0

var base_decay_time: float
var base_smog_change: float
var base_growth_speed_factor: float
var base_color: Color
var base_generation: int

# var _base_decay_time: float # need to have resource, created in level,
# and reference it
# use game for now ?
func apply_mutation_as_base():
	Global.gene_base_decay_time = base_decay_time
	Global.gene_base_smog_change = base_smog_change
	Global.gene_base_growth_factor = base_growth_speed_factor
	Global.gene_base_color = base_color
	Global.gene_base_generation = base_generation + 1
	Global.gene_base_generation_origin = base_generation
	Global.gene_base_mutation_id_origin = mutation_id

func _init(coords, size, building_type, growth, ui_radius, state=ModelObject.State.None, health=100):
	super(GameTypes.Type.Building, coords, health)
	_size = size
	# TODO: move to resource.
	# Apply gene progression to default mushroom, this should be per type ?
	base_decay_time = Global.gene_base_decay_time
	base_smog_change = Global.gene_base_smog_change
	base_growth_speed_factor = Global.gene_base_growth_factor
	base_color = Global.gene_base_color
	base_generation = Global.gene_base_generation

	_growth = growth
	_building_type = building_type
	_building_category = type_to_category.get(building_type)
	_state = state
	_resource = null
	_harvester = null
	_storage = {}
	_production_active = false
	_resource_storage_type = self.get_resource_stored_type()
	max_radius = BuildingObject.get_radius_for(_building_type) # define in data files
	min_radius = 1
	radius = ui_radius
	collection_rate = 0.0
	#if get_building_category(_building_type) == StructureCategory.Storage:
		#collection_radius = radius
		#collection_rate = 1.0
		#_sclerotia = Sclerotia.new()
		#_sclerotia.max_radius = 4
		#_sclerotia.min_radius = 1
		#_sclerotia.radius = 1
		#_sclerotia.collection_radius = _sclerotia.radius
		#_sclerotia.collection_rate = 1.0 # would be set by controller
		#set_value("_sclerotia.max_radius", 10) # <- that does not work

	pass

func get_growth():
	return _growth

func _ready():
	pass
	if get_state() == ModelObject.State.None:
		set_state(BuildingState.Building)

func get_growth_cost():
	return growth_cost.get(get_building_type())

static func get_growth_cost_static(building_type, radius):
	var adjusted_cost: Dictionary = {}
	var building_costs = growth_cost.get(building_type)
	for resource_type in building_costs.keys():
		# adjust for radius
		var adjusted_to_radius: float = building_costs[resource_type] * radius
		adjusted_cost[resource_type] = adjusted_to_radius
	return adjusted_cost

static func get_growth_cost_preview(building_type, radius):
	var cost: Dictionary = growth_cost.get(building_type).duplicate()
	for resource_type in cost.keys():
		cost[resource_type] = cost[resource_type] * radius # todo use dict scale cost[radius]
	return cost

static func costs_to_string(costs: Dictionary):
	var component: Array = []
	for type in GameTypes.ResourceType.values(): #TODO use proxy function so we can exclude none
		if costs[type] > 0:
			component.append("%s: %d" % [GameTypes.ResourceType.keys()[type], costs[type]])
	return "; ".join(component)

# FIXME: move to level data, or some other data thing
func get_default_storage_amount():
	return 100 * get_radius()

func get_storage_limit():
	#var that is updated after building is build
	return _storage

func set_storage_limit(type, value):
	var prev_value = _storage.duplicate()
	_storage[type] = value
	state_changed.emit({# check if state is diff from prev: FIXME:
		'type': _type,
		'object': self,
		'resource_type': type,
		'prop': 'StorageLimit',
		'prev': prev_value,
		'curr': value,
	})

	# emit change building changed?
	# than this would actually change tally_storage ?

func apply_storage_limit():
	var capability = get_storage_limit_capability()
	for resource_type in capability.keys():
		set_storage_limit(resource_type, capability[resource_type])

func get_storage_limit_capability():
	var default_storage = get_default_storage_amount() # ? vary by _building_type
	var storage_dict:Dictionary = {}
	match get_building_type():
		StructureType.Storage_Water:
			storage_dict = {GameTypes.ResourceType.Water: default_storage}
		StructureType.Storage_Energy:
			storage_dict = {GameTypes.ResourceType.Energy: default_storage}
		StructureType.Storage_Minerals:
			storage_dict = {GameTypes.ResourceType.Minerals: default_storage}
		StructureType.Storage_Carbon:
			storage_dict = {GameTypes.ResourceType.Carbon: default_storage}
	return storage_dict

func get_category():
	return _building_category

static func get_building_category(building_type):
	return type_to_category.get(building_type, -1)
# need not static function as well
static func get_building_category_string(building_type):
	return category_names[get_building_category(building_type)]
static func get_category_string(category: StructureCategory):
	return category_names[category]

func get_structure_full_name() -> String:
	return "%s %s" % [
		BuildingObject.names.get(get_building_type()),
		BuildingObject.get_building_category_string(get_building_type())
		]

func get_tile_coords():
	# NOTE: check can we use ModelObject.get_tile_coords()
	var building_coords = []

	for dx in _size.x:
		for dy in _size.y:
			building_coords.push_back(_coords + Vector2i(dx, dy))

	return building_coords

func get_smog_absorption_coords():
	var absorption_cords = []

	var smog_absorption_radius = get_radius()
	#var smog_absorption_radius = BuildingObject.get_smog_radius_for_type(_building_type)

	absorption_cords = LevelController.get_level_controller().get_coords_in_circle(_coords, smog_absorption_radius)

	return absorption_cords

func get_radiation_absorption_coords():
	var absorption_cords = []

	var radiation_absorption_radius = get_radius()
	#var radiation_absorption_radius = BuildingObject.get_radiation_radius_for_type(_building_type)

	absorption_cords = LevelController.get_level_controller().get_coords_in_circle(_coords, radiation_absorption_radius)

	return absorption_cords

func get_size():
	return _size

func get_building_type():
	return _building_type

func get_resource_stored_type():
	match _building_type:
		BuildingObject.StructureType.Storage_Carbon:
			return GameTypes.ResourceType.Carbon
		BuildingObject.StructureType.Storage_Water:
			return GameTypes.ResourceType.Water
		BuildingObject.StructureType.Storage_Energy:
			return GameTypes.ResourceType.Energy
		BuildingObject.StructureType.Storage_Minerals:
			return GameTypes.ResourceType.Minerals
		_:
			return -1
	return -1 # replace later with ResourceObject.ResourceType.None

var radiation_extraction_rate = 0.1 # amount of extration per tick - 1s
# For smog
var smog_extraction_rate = 0.1 # amount of extration per tick - 1s
# or just general extraction rate
var energy_consumption = 0.1  # Energy consumed per tile per tick for operation


var process_coords: Array
var can_process_coords: Dictionary # if on activation the value was >=1
var processing_coords_amount: int # how many of these we have

# radiation
var last_energy_input: float
var last_minerals_input: float
var last_energy_output: float
# smog
# smog processed ?
var last_minerals_output: float
# common
var last_enzymes_consumed: float

# for use in storage
var last_carbon_input: float
var last_water_input: float

var last_resource_input: Dictionary = {
		GameTypes.ResourceType.Water: 0.0,
		GameTypes.ResourceType.Energy: 0.0,
		GameTypes.ResourceType.Minerals: 0.0,
		GameTypes.ResourceType.Carbon: 0.0,
	}
var resource_store: Dictionary = {
		GameTypes.ResourceType.Water: 0.0,
		GameTypes.ResourceType.Energy: 0.0,
		GameTypes.ResourceType.Minerals: 0.0,
		GameTypes.ResourceType.Carbon: 0.0,
	}

var _production_active: bool
func set_production_active(active: bool):
	var prev = _production_active
	if active != prev:
		_production_active = active
		var change: Dictionary = {
			'curr': active,
			'prev': prev,
			'coords': _coords,
			'type': 'production_active',
		}
		building_changed.emit(change)

signal view_changed(change)

# export center
# class_name ExportCenter ?
var export_enabled: bool

var export_radius: int = 1

var export_tiles_amount: int
var export_resource_levels_percent = {
	GameTypes.ResourceType.Water: 0,
	GameTypes.ResourceType.Minerals: 0,
}
var desired_resource_levels = {
	GameTypes.ResourceType.Water: 3,  # Maintain 5 units of water
	GameTypes.ResourceType.Minerals: 1,  # Maintain 3 units of minerals
}
var total_accumulated_carbon: float
var smog_penalty_percent_avg: float

var _ui_selected: bool
func set_selected(value):
	var prev = _ui_selected
	if value != prev:
		_ui_selected = value
		var change: Dictionary = {
			'curr': value,
			'prev': prev,
			'coords': _coords,
			'type': 'ui_selected',
		}
		building_changed.emit(change)
func get_selected():
	return _ui_selected

func set_value(key, value):
	var prev = self.get(key)
	if value != prev:
		self.set(key, value)
		var change: Dictionary = {
			'curr': value,
			'prev': prev,
			'coords': _coords,
			'type': 'set_value',
			'prop': key,
		}
		building_changed.emit(change)

func get_value(key):
	return self.get(key)

# Calculate and store the percent of maximum production achieved
var production_efficiency: float
# Indicate if we are missing resources for full capacity
var missing_resources_for_full_capacity: bool

static var scale_size_by_radius: Dictionary = {
	1: Vector2(0.4, 0.4),
	2: Vector2(0.6, 0.6),
	3: Vector2(0.8, 0.8),
	4: Vector2(1.0, 1.0),
	5: Vector2(1.2, 1.2),
}
