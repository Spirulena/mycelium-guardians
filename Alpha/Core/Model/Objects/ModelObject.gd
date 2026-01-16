extends Resource
class_name ModelObject

static var State = {
	"None": "none",
	"Removed": "removed",
	"Crashed": "crashed",
}

var _type: String
var type: String:
	get:
		return _type

var _coords: Vector2i
var coords: Vector2i:
	get:
		return _coords

var _state: String
var _time_in_state: float
var _health: float

var _size: Vector2i
var size: Vector2i:
	get:
		return _size
	set(val):
		_size = val

var _name: String
var name: String:
	get:
		return _name

signal state_changed(change)
signal health_changed(change)

func _init(type, coords, health = 100):
	_name = "Base model object"
	_type = type
	_coords = coords
	_state = State.None
	_health = health
	_size = Vector2i(1, 1)

func get_state():
	return _state

func set_state(state: String):
	var prev_state = _state
	_state = state
	if _state != prev_state:
		_time_in_state = 0
		state_changed.emit({
			'type': _type,
			'object': self,
			'prop': 'state',
			'prev': prev_state,
			'curr': state,
		})

func get_time_in_state():
	return _time_in_state

func increase_time_in_state(delta: float):
	_time_in_state += delta

func get_health():
	return _health

func set_health(new_health: float):
	new_health = clamp(new_health, 0, 100)

	if new_health != _health:
		var prev_health = _health
		_health = new_health
		if new_health >= 100:
			health_changed.emit({
				'type': _type,
				'prop': 'health',
				'prev': prev_health,
				'curr': new_health,
			})
			return true
	return false

func get_degradation():
	return 100 - _health

func change_health(amount: float):
	var new_amount = get_health() + amount
	if is_zero_approx(new_amount) or new_amount < 0:
		new_amount = 0
	return set_health(new_amount)

func get_tile_coords() -> Array[Vector2i]:
	var tile_coords: Array[Vector2i] = []

	for dx in _size.x:
		for dy in _size.y:
			tile_coords.push_back(_coords + Vector2i(dx, dy))

	return tile_coords
