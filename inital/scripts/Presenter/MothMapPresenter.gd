class_name MothMapPresenter extends Node2D

var _parent
var _controller
var _model

func _init(model, parent):
	_model = model
	_parent = parent
	_controller = MothController.new(model)
	_model.movable_changed.connect(_movable_changed)
	y_sort_enabled = true

func _movable_changed(change):
	if change.type == 'movement':
		var coords = _model.get_coords()
		var movement = _model.get_movement()

		var curr_position = _parent.to_position(coords)
		var next_position = _parent.to_position(coords + movement.v)

		self.position = curr_position.lerp(next_position, movement.t)

func _ready():
	self.position = _parent.to_position(_model.get_coords())
	var instance = Loader.get_loader().return_scene("moths").instantiate()
	add_child(instance)
	
	add_child(_controller)
