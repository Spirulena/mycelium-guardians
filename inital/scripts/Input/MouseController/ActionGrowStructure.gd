extends ActionHandler
class_name ActionGrowStructure

var building_id: BuildingObject.StructureType
var _instance# What is the type here ?
var _radius: int
var _max_radius: int

func _init(parent: MouseController):
	super(parent, GUIController.Actions.GrowStructure)
	building_id = -1

func reset():
	super.reset()
	parent.view_changed({
		'type': GUIController.Actions.GrowStructure,
		'state': 'cancelled',
		'curr': building_id,
		'coords': null,
		'instance': _instance,
	})
	building_id = -1

func set_building_id(building_id: BuildingObject.StructureType):
	self.building_id = building_id
	self._max_radius = get_max_radius()
	self.set_radius(1)
	parent.view_changed({
		'type': GUIController.Actions.GrowStructure,
		'state': 'selected',
		'coords': null,
		'prev': -1,
		'curr': building_id,
		'radius': get_radius(),
		'store': func(instance): _instance = instance,
	})

func handle_press(coords: Vector2i):
	is_executing = true

func handle_move(coords: Vector2i):
	parent.set_highlight(coords, true)

	if not is_executing and building_id != -1:
		parent.view_changed({
			'type': GUIController.Actions.GrowStructure,
			'state': 'moving',
			'coords': coords,
			'building_id': building_id,
			'radius': get_radius(),
			'instance': _instance,
		})

func handle_release(coords: Vector2i):
	if is_executing and building_id != -1:
		parent.view_changed({
			'type': GUIController.Actions.GrowStructure,
			'state': 'place_request',
			'coords': coords,
			'instance': _instance,
			'radius': get_radius(),
			'building_id': building_id,
		})
	is_executing = false

func get_radius() -> int:
	return _radius

func set_radius(radius: int):
	var prev = get_radius()
	radius = clampi(radius, 1, _max_radius)
	if radius != _radius:
		_radius = radius
		parent.view_changed({
			'type': GUIController.Actions.GrowStructure,
			'state': 'change_radius',
			'coords': null,
			'instance': _instance,
			'radius': _radius,
			'curr': _radius,
			'prev': prev,
			'building_id': building_id,
		})

func change_radius(radius: int):
	var prev = get_radius()
	# or clamp here ?
	set_radius(prev + radius)

func get_max_radius():
	return BuildingObject.get_radius_for(building_id)
