class_name MothStateTrackWorm extends MothState

var _model
var _next_state

func _init(model, next_state):
	_model = model
	_next_state = next_state

func get_next():
	# TODO: get actual worm location
	var nearest_worm = Vector2i(10, 10)
	var coords = _model.get_coords()

	if coords == nearest_worm:
		return {
			"direction": Vector2i( 0, +1),
			"state": _next_state,
		}
	else:
		var d = nearest_worm - coords
		d.x /= abs(d.x)
		d.y /= abs(d.y)
		return {
			"direction": d,
			"state": self,
		}
