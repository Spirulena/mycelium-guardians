extends ModelObject
class_name ResourceObject

enum ResourceType {
	Water = 0,
	Energy = 1,
	Minerals = 2,
	Carbon = 3,
	Acid = 4,
	Enzymes = 6,
}
enum SubResourceType {
	Acid = 4,
	Smog = 5,
}
var names: Dictionary = {
	0: 'Water',
	1: 'Energy',
	2: 'Minerals',
	3: 'Carbon',
	4: 'Acid',
	6: 'Enzymes',
}
var names2: Dictionary = {
	ResourceType.Water: 'Water',
	ResourceType.Energy: 'Energy',
	ResourceType.Minerals: 'Minerals',
	ResourceType.Carbon: 'Carbon',
	ResourceType.Acid: 'Acid',
	ResourceType.Enzymes: 'Enzymes',
}
# FIXME:
static func return_resources():
	pass
	# replace all usage of ResourceObject.ResourceType.values()  and keys in code
	# Could filer out ResourceType.None

static var _colors: ResourceColors

var _resource_type: ResourceObject.ResourceType
var _resource_amount: float

signal resource_changed(change)

func _init(coords, resource_type, resource_amount):
	super(ModelObject.Type.Resource, coords)
	_resource_type = resource_type
	_resource_amount = resource_amount
	_colors = load("res://UI/CustomResources/default_resources_colors.tres")

func get_resource_name():
	return names2.get(_resource_type, "??")
	#var types = ResourceObject.ResourceType.keys()
	#if not ResourceObject.ResourceType.keys().has(_resource_type):
		#return "Unknown"
	#else:
		#return ResourceObject.ResourceType.keys()[_resource_type]

func get_resource_type():
	return _resource_type

func get_resource_amount() -> float:
	return _resource_amount

func set_resource_amount(amount):
	var prev = get_resource_amount()
	var curr = amount
	_resource_amount = amount
	# Capture curr < 0 to delete resource ?
	# and self delete ?
	resource_changed.emit({
		'type': 'ResourceObjectChanged',
		'coords': get_coords(),
		'prev': prev,
		'curr': curr,
	})
	if curr < 0 or is_zero_approx(curr):
		LevelController.get_level_controller().remove_object(self)
		#set_state(ModelObject.State.Removed)

func change_resource_amount(change):
	var curr = get_resource_amount()
	var new = curr + change
	# TODO: cap to 0 ?
	set_resource_amount(new)

# Move this static to Utils ?
static func get_resource_type_string(type):
	return ResourceType.keys()[type]

static func get_resource_type_color(type):
	return _colors.resource_color[type]
