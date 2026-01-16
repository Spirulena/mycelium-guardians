class_name LevelController extends Node2D

static var _level_controller
static func get_level_controller() -> LevelController:
	if not is_instance_valid(_level_controller):
		_level_controller = LevelController.new()
	return _level_controller

signal model_changed

var _level_data: LevelData
var level_data: LevelData:
	get:
		return _level_data

func _init():
	name = "LevelController"
	_level_data = LevelData.new() as LevelData
	_level_data.model_changed.connect(_model_changed)

func _model_changed(change: Dictionary):
	model_changed.emit(change)

func add_object(object: ModelObject):
	_level_data.add_object(object)
