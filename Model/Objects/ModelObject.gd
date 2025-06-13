extends Resource
class_name ModelObject

static var Type = {
	"AIPanel": "ai_panel",
	"Building": "building",
	"Harvester": "harvester",
	"Ruin": "ruin",
	"Mycelium": "mycelium",
	"MyceliumQueue": "mycelium_queue",
	"MyceliumGrowing": "mycelium_growing",
	"Enzyme": "enzyme",
	"Resource": "resource",
	"Creature": "creature", # Movable
	"Plant": "plant",
	"ResourceBall": "resource_ball" # Movable
}

static var State = {
	"None": "none",
	"Removed": "removed",
	"Crashed": "crashed",
}

var _type: String
var _coords: Vector2i
var _state: String
var _time_in_state: float
var _health: float
var _size: Vector2i

signal state_changed(change)
signal health_changed(change)

func _init(type, coords, health = 100):
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
# TODO: look, is it still needed ?
func set_health(new_health: float):
	new_health = clamp(new_health, 0, 100)

	if new_health != _health:
		var prev_health = _health
		_health = new_health
		if new_health >= 100:
			health_changed.emit({
				'type': get_type(),
				'prop': 'health',
				'prev': prev_health,
				'curr': new_health,
			})
			#print('health changed ', new_health)
			return true
	return false

func get_degradation():
	return 100 - _health

func change_health(amount: float):
	var new_amount = get_health() + amount
	if is_zero_approx(new_amount) or new_amount < 0:
		new_amount = 0
	return set_health(new_amount)

func get_type():
	return _type

func get_coords() -> Vector2i:
	return _coords

func get_size():
	return _size

func set_size(size: Vector2i):
	_size = size

func get_tile_coords() -> Array[Vector2i]:
	var size = get_size()

	var tile_coords: Array[Vector2i] = []

	for dx in size.x:
		for dy in size.y:
			tile_coords.push_back(get_coords() + Vector2i(dx, dy))

	return tile_coords
