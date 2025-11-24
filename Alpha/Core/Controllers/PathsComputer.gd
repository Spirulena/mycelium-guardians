extends Node
class_name PathsComputer

const DIST_MAX = 1000000

var _distance
var _queue_update: bool
var _lc: LevelController
func _init(level_controller):
	_lc = level_controller
	_distance = {}
	_queue_update = false

func recompute_paths(start_coords, start_distance):
	var pq = BinaryHeap.new()

	pq.upsert({
		'coords': start_coords,
		'distance': start_distance,
	})

	while not pq.empty():
		var candidate = pq.pop()
		var coords = candidate.coords
		var distance = candidate.distance

		if distance <= _distance.get(coords, DIST_MAX):
			_distance[coords] = distance

			for neighbor in _neighbors(coords):
				if distance + 1 < _distance.get(neighbor, DIST_MAX):
					pq.upsert({
						'coords': neighbor,
						'distance': distance + 1,
					})

func distance_to_base(coords):
	return _distance.get(coords, DIST_MAX)

func connected_to_base(coords):
	return _distance.get(coords, DIST_MAX) < DIST_MAX

func _neighbors(coords):
	var neighbors = []

	var offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for offset in offsets:
		if _lc.is_mycelium_at(coords + offset):
			neighbors.push_back(coords + offset)

	return neighbors

func neighbors_connected_to_base(coords):
	for neighbor in _neighbors(coords):
		if connected_to_base(neighbor):
			return true

	return false

func get_next_to_base(coords):
	var best_path_to_base = {
		'coords': coords,
		'distance': DIST_MAX,
	}

	for neighbor in _neighbors(coords):
		if _distance.get(neighbor, DIST_MAX) < best_path_to_base.distance:
			best_path_to_base = {
				'coords': neighbor,
				'distance': _distance[neighbor],
			}

	if best_path_to_base.distance < DIST_MAX:
		return [best_path_to_base.coords]
	else:
		return []

func queue_update_paths():
	_queue_update = true

func update_paths():
	_distance = {}
	recompute_paths(_lc.get_base_coords()[0], 0)
	_lc.model_changed.emit({
		'type': 'PathsComputer',
		'prop': 'update_paths',
		'prev': null,
		'curr': true,
		})

func update_if_requested():
	if _queue_update:
		update_paths()
		_queue_update = false
	#_queue_update = false
