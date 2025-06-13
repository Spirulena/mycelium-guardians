class_name DegradationController extends Node2D

var _model

func _init(model):
	_model = model

func _ready():
	pass

func _process(delta):
	if _model.get_state() == BuildingObject.BuildingState.Building:
		return

	var coords = _model.get_coords()
	var level_controller = LevelController.get_level_controller()

	var smog_amount = clamp(level_controller.get_smog(coords), 0, 10)
	var radiation_level = clamp(level_controller.get_radiation(coords), 0, 10)

	var degradation_rate = 1

	var degradation = -pow(degradation_rate, -1) * ((smog_amount + radiation_level) / 2.0) * delta
	_model.change_health(degradation)
