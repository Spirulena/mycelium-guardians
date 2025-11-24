class_name RuinController extends Node


var _model: RuinObject

func _init(model):
	_model = model

func _ready():
	name = "RuinController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

	for resource in _model.get_resources():
		resource.state_changed.connect(_resource_state_changed)
# Ruin needs to track all resources, or harvesters in model
# Yes store resource object in ruin as it is from where it belongs

#  monitor, the resources, and delete ruin when all resources are extracted

func _resource_state_changed(change):
	var check: bool = true
	#print(change)
	if change.curr == ModelObject.State.Removed:

		for resource in _model.get_resources():
			var amount = resource.get_resource_amount()
			if not is_zero_approx(resource.get_resource_amount()):
				check = false
		#print("check all resources: ", check)
		if check:
			LevelController.get_level_controller().remove_object(_model) # remove ruin

func _process(delta: float) -> void:
	pass
