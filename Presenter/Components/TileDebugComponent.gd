class_name TileDebugComponent extends ViewComponent

func _ready() -> void:
	add_child(TileDebugPresenter.new(_view))
