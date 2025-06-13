extends ModelObject
class_name HarvesterObject

# TODO: add enzymes usage

var _resource_object: ResourceObject
var _time_producing_enzyme: float
var last_extracted_amount: float
var accumulated_extraction: float
var _ruin: RuinObject

static var HarvesterState = {
	"Idle": "idle",
	"Harvesting": "harvesting",
	"Depleted": "depleted",
	# TODO: Depleted, Done ?
}

func _init(coords):
	_time_producing_enzyme = 1 # in sec
	super(ModelObject.Type.Harvester, coords)
	set_state(HarvesterState.Idle)
	last_extracted_amount = 0.0
	accumulated_extraction = 0.0

func get_time_producing_enzyme():
	return _time_producing_enzyme

func get_resource_type():
	return _resource_object.get_resource_type()

func get_resource_object() -> ResourceObject:
	return _resource_object

func set_resource(resource):
	_resource_object = resource
