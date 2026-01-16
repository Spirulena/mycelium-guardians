extends ModelObject
class_name MovableObject

var _movement: Dictionary

signal movable_changed(change: Dictionary)

func _init(type, coords, health):
	super(type, coords, health)
	_name = "Movable"

	_movement = {
		"v": Vector2i(0, 0),
		"t": 0.0,
	}

func get_movement():
	return _movement

func set_direction(v):
	var prev_m = _movement.duplicate()
	_movement.v = v

	movable_changed.emit({
		"type": 'direction',
		"prev": _coords,
		"curr": _coords,
		"prev_movement": prev_m,
		"movement": _movement,
	})

func update_movement(t):
	_movement.t = t

	# NOTE: removing for test
	#movable_changed.emit({
		#"type": 'movement',
		#"prev": _coords,
		#"curr": _coords,
		#"movement": _movement,
	#})

func set_coords(coords):
	_movement.t = 0
	_movement.v = Vector2i(0, 0)

	movable_changed.emit({
		"type": 'tile',
		"prev": _coords,
		"curr": coords,
	})

	_coords = coords
