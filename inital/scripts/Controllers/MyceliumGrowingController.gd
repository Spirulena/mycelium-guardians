class_name MyceliumGrowingController extends Node2D

var _model: MyceliumGrowingObject
var _lc: LevelController
var timer: Timer
var _neighbours: Dictionary
var triggered: bool

func _init(model):
	triggered = false
	_model = model
	_lc = LevelController.get_level_controller()
	name = "MyceliumGrowingController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	_neighbours = {
		Vector2i.UP: false,
		Vector2i.DOWN: false,
		Vector2i.LEFT: false,
		Vector2i.RIGHT: false,
	}

func _ready():
	randomize()
	timer = Timer.new()
	timer.wait_time = randf_range(0.2, 0.45)
	timer.timeout.connect(transition_to_next_state)
	add_child(timer)
	timer.start()

func transition_to_next_state():
	if triggered:
		print_stack()
		return
	triggered = true
	timer.stop()
	_lc.remove_object(_model)
	# func _init(coords, health = 1, myc_gfx_index: int = 0):
	_lc.add_object_guarded(MyceliumObject.new(_model.get_coords(), 1, _model._mycelium_gfx_index))

func get_neighbours():
	var coords = _model.get_coords()
	for direction in _neighbours.keys():
		_neighbours[direction] = _lc.have_neighbor_to(coords, direction)
	return _neighbours
