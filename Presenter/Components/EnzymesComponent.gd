class_name EnzymesComponent extends ViewComponent

func _ready() -> void:
	add_child(EnzymesMyceliumController.new(_lc))
