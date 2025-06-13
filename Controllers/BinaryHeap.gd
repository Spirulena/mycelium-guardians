extends Object
class_name BinaryHeap

var _heap
var _next_pos
var _coords_to_pos

func _init():
	_heap = []
	_coords_to_pos = {}
	_heap.push_back({
		'distance': -1
	})
	_next_pos = 1 

func _bubble_up(pos):
	var parent_pos = pos/2
	if _heap[pos].distance < _heap[parent_pos].distance:
		_swap(pos, parent_pos)
		_bubble_up(parent_pos)

func _swap(pos1, pos2):
	var t = _heap[pos1]
	_heap[pos1] = _heap[pos2]
	_heap[pos2] = t
	_coords_to_pos[_heap[pos1].coords] = pos1
	_coords_to_pos[_heap[pos2].coords] = pos2

func _sink_down(pos):
	var child1_pos = 2*pos
	var child2_pos = 2*pos+1
	var smallest_child_pos = child1_pos

	if pos >= _next_pos:
		return

	if child1_pos >= _next_pos:
		return

	if child2_pos < _next_pos and _heap[child2_pos].distance < _heap[smallest_child_pos].distance:
		smallest_child_pos = child2_pos

	if  _heap[smallest_child_pos].distance < _heap[pos].distance:
		_swap(pos, smallest_child_pos)
		_sink_down(smallest_child_pos)

func empty():
	return _next_pos == 1

func upsert(graph_node):
	var pos = _coords_to_pos.get(graph_node.coords, -1)

	if pos == -1:
		pos = _next_pos
		_heap.resize(_next_pos + 1)
		_next_pos += 1

	_heap[pos] = graph_node
	_coords_to_pos[graph_node.coords] = pos
	_bubble_up(pos)

func pop():
	var graph_node = _heap[1]
	_swap(1, _next_pos - 1)
	_next_pos -= 1
	_sink_down(1)
	_coords_to_pos.erase(graph_node.coords)
	return graph_node
