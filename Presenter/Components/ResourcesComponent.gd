class_name ResourcesComponent extends ViewComponent

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = true

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == 'Resource':
		_gui.resource_changed(change)

	elif change.type == 'ResourceLimit':
		_gui.resource_limit_changed(change)

	#elif change.type == 'enzymes_amount':
		#_gui.enzymes_changed(change)
