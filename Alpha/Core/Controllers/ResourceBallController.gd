class_name ResourceBallController extends Node2D

var _model: ResourceBallObject
var _lc: LevelController
func _init(model):
	_lc = LevelController.get_level_controller()
	_model = model
	_model.set_direction(get_next().direction)
	_model.movable_changed.connect(_movable_changed)

func _movable_changed(change):
	if change.type == 'tile':
		# TODO: Move to ChanceController
		#print(change)
		_lc.get_tile_at(change.curr).change_chance('plants', 0.01)
		# TODO: add decay.

func get_next():
	if _model.get_coords() == _lc.get_base_coords()[0]:
		_lc.change_tally(_model.get_resource_type(), _model.get_resource_amount())
		_lc.remove_movable(_model)

	var direction = Vector2i.ZERO
	var distance = PathsComputer.DIST_MAX

	for c_dir in [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]:
		var c_dist = _lc.distance_to_base(_model.get_coords() + c_dir)
		if c_dist < distance:
			distance = c_dist
			direction = c_dir

	if direction == null:
		direction = Vector2i.ZERO
	return {
		"direction": direction,
	}

func _ready():
	pass

func _process(delta):
	#var coords = _model.get_coords()
	#if coords == null:
		#return
	#var movement = _model.get_movement()
#
	## TODO: Boran: Not sure what movement.v was null
	## TODO: remove that dirty fix, and fix root cause
	#if movement.v == null:
		#movement.v = Vector2i.ZERO

	_model._movement.t += delta
	#if _model._movement.t <= 1:
		#pass
		# ignore t ?, cos compute localy and update only v
		#_model.update_movement(movement.t)
	#else:
	if _model._movement.t >= 1:
		_model.set_coords(_model._coords + _model._movement.v)
		var next = get_next()
		_model.set_direction(next.direction)
