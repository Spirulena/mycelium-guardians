class_name AIPanelComponent extends ViewComponent

@onready var panels_tile_map

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = true

	# TODO: can remove container, component is the container

	# panels_tile_map
	panels_tile_map = TileMap.new() as TileMap
	panels_tile_map.z_index = 50
	panels_tile_map.y_sort_enabled = true
	panels_tile_map.z_as_relative = true
	panels_tile_map.set_layer_y_sort_enabled(0, true)
	panels_tile_map.tile_set = Loader.get_loader().return_scene("panels_tile_set")
	add_child(panels_tile_map)

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.AIPanel:
		if change.prev == null:
			add_child(AIPanelMapPresenter.new(change.curr, _view, panels_tile_map))
