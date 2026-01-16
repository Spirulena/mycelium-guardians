class_name LevelData extends Resource

var _tile_at_coords: Dictionary[Vector2i, TileObject]
var tiles: Dictionary[Vector2i, TileObject]:
	get:
		return _tile_at_coords

signal model_changed(event: Dictionary)

func _init():
	_tile_at_coords = {}

func tile_changed(change: Dictionary):
	model_changed.emit(change)

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

func add_object(object: ModelObject):
	for coord in object.get_tile_coords():
		if coord not in _tile_at_coords:
			_tile_at_coords[coord] = TileObject.new(coord)
		_tile_at_coords[coord].add_object(object)

	model_changed.emit({
		'type': object.type,
		'coords': object.coords,
		'prev': null,
		'curr': object,
	})

func remove_object(object: ModelObject):
	for coord in object.get_tile_coords():
		if object.coords not in _tile_at_coords:
			_tile_at_coords[object.coords] = TileObject.new(object.coords)
		_tile_at_coords[object.coords].remove_object(object)

	model_changed.emit({
		'type': object.type,
		'coords': object.coords,
		'prev': object,
		'curr': null,
	})
