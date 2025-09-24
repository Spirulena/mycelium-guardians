class_name HighlightComponent extends ViewComponent

@onready var tile_selection

func _ready() -> void:
	# Tile selection
	tile_selection = Loader.get_loader().return_scene("LegacyTileSelection").instantiate()
	tile_selection.z_index = 60
	tile_selection.z_as_relative = false
	add_child(tile_selection)

func handle_view_change(change):
	if super.handle_view_change(change):
		return

	# highlight tile
	if (change.type == 'set_highlight'):
		tile_selection.on_tiles_highlighted(change.coords, change.size, change.highlight)
