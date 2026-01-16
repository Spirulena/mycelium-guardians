extends Resource
class_name TileObject
## Holds Tile Data

var _coords: Vector2i
var _layers: Array[ModelObject]
var _resources: Array[int]
var _discovered: bool

signal tile_changed(change: Dictionary)

var coords: Vector2i:
	get:
		return _coords

var discovered: bool:
	get:
		return _discovered
	set(val):
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
			return true
		return false

var layers: Array[ModelObject]:
	get:
		return _layers

var resources:
	get:
		return _resources

func get_resource_level(type: GameTypes.ResourceType):
	return _resources[type]

func _init(coords):
	_coords = coords
	_layers = []
	_layers.resize(GameTypes.Layer.NUM_LAYERS)
	_layers.fill(null)
	_resources.resize(GameTypes.ResourceType.NUM_RESOURCES)
	_resources.fill(0.0)
	_discovered = false

func model_changed(change: Dictionary):
	pass

func add_object(object: ModelObject):
	_layers[GameTypes.object_to_layer_map[object.type]] = object

func remove_object(object: ModelObject):
	_layers[GameTypes.object_to_layer_map[object.type]] = null
