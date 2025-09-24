class_name FFCrasherStateSignalObstacle extends FFCrasherState

var _model: MovableObject
var _destination
var _start_position
var _end_position
var _lc: LevelController
var _wait_tick
var _max_wait

func _init(model, destination, max_wait = 3):
	_model = model
	_start_position = _model.get_coords()
	_end_position = destination
	_destination = destination #Vector2i(0, 0)
	_lc = LevelController.get_level_controller()
	_wait_tick = 0
	_max_wait = max_wait

func get_next():
	# Intermediate state, Try all directions for movement.
	# wait here ?
	# signal flare

	# Obstacle still there, not moving.
	# Increase the tick
	_wait_tick += 1
	if _wait_tick > _max_wait:
		# self destruct
		return {
			"direction": Vector2i.ZERO,
			"state": FFCrasherStateSelfDestruct.new(_model),
		}

	return {
		"direction": Vector2i.ZERO,
		"state": self,
	}
