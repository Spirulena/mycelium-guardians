class_name HarvesterComponent extends ViewComponent

func _ready() -> void:
	z_index = 0
	z_as_relative = false
	y_sort_enabled = true

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Harvester:
		if change.prev == null:
			add_child(HarvesterMapPresenter.new(change.curr, _view))
