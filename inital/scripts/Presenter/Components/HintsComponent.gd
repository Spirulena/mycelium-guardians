class_name HintsComponent extends ViewComponent

func _ready() -> void:
	add_child(HintController.new(_view))
