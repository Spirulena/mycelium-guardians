class_name FFCrasherStateTrackBase extends FFCrasherState

var _model
var _next_state
var _destination

func _init(model, destination, next_state):
	_model = model
	_next_state = next_state
	_destination = destination #Vector2i(0, 0)

func get_next():
	# TODO: get actual worm location
	var coords = _model.get_coords()

	if coords == _destination:
		return {
			"direction": Vector2i( 0, +1),
			"state": _next_state,
		}
	else:
		var d = _destination - coords
		# Directly use the sign function to get -1, 0, or 1
		d.x = sign(d.x)
		d.y = sign(d.y)

		return {
			"direction": d,
			"state": self,
		}
