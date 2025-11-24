class_name MothController extends Node

var _model
var _state

func _init(model):
	_model = model

	# TODO: Use the model object state for this, then map back to state machine
	_state = MothStateTrackWorm.new(model, MothStateCircleWorm.new(model))
	_model.set_direction(_state.get_next().direction)

func _ready():
	pass

func _process(delta):
	var coords = _model.get_coords()
	var movement = _model.get_movement()

	movement.t += delta
	if movement.t <= 1:
		_model.update_movement(movement.t)
	else:
		_model.set_coords(coords + movement.v)
		var next = _state.get_next()
		_state = next.state
		_model.set_direction(next.direction)
