class_name FFCrasherStateSelfDestruct extends FFCrasherState

var _model: MovableObject

func _init(model):
	_model = model

# Do the destriction here ?
func get_next():
	return {
		"direction": Vector2i.ZERO,
		"state": self,
	}
