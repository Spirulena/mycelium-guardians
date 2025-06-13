class_name MothStateCircleWorm extends MothState

var _model
var _movement_pattern
var _movement_pattern_i

func _init(model):
	_model = model
	_movement_pattern = [
		Vector2i(+1, -1),
		Vector2i(-1, -1),
		Vector2i(-1, +1),
		Vector2i(+1, +1),
	]
	_movement_pattern_i = 0

func get_next():
	var curr_movement_pattern = _movement_pattern[_movement_pattern_i]
	_movement_pattern_i = (_movement_pattern_i + 1) % len(_movement_pattern)
	return {
		"direction": curr_movement_pattern,
		"state": self,
	}
