class_name HealthController extends Node

var _model: ModelObject

func _init(model):
	_model = model
	_model.health_changed.connect(_health_changed)

func _health_changed(change):
	if change.curr <= 0:
		LevelController.get_level_controller().remove_object(_model)

func _ready():
	pass
