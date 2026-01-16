class_name PlantObject extends ModelObject

enum PlantType {DryGrass, Flower, Bush, Tree01, Tree02, RoundCane_01 }

var _plant_scene_key: Dictionary

var _subtype: PlantType

# If in smog, will die faster and will leave less carbon.

# Could also just use health. When growing slowly increase health.
# Drive animation with health

var base_carbon_production_rate = 0.01  # Example value, adjust based on plant type and other factors
var water_consumption_rate = 0.05
var minerals_consumption_rate = 0.03

var carbon_accumulated: float = 0.0
var smog_penalty_percent: float
static var PlantState = {
	"Fruiting": "fruiting",
	"Growing": "growing",
	"Crashed": "crashed",
}
func _init(coords, subtype, health):
	super(GameTypes.Type.Plant, coords, health)
	_subtype = subtype
	_plant_scene_key = {
		PlantType.DryGrass: "dry_grass",
		PlantType.Flower: "flower",
		PlantType.Bush: "bush",
		PlantType.Tree01: "tree_01",
		PlantType.Tree02: "tree_02",
		PlantType.RoundCane_01: "round_cane_01",
	}
	_name = _plant_scene_key[subtype]
	set_state(PlantState.Growing)

func get_subtype():
	return _subtype

func get_scene_key():
	return _plant_scene_key.get(self._subtype)

# accumulate to tile
func accumulate_carbon(carbon_production_rate):
	carbon_accumulated += carbon_production_rate

# TODO: move to tile
func collect_carbon() -> float:
	var carbon_to_collect = carbon_accumulated
	carbon_accumulated = 0
	return carbon_to_collect
