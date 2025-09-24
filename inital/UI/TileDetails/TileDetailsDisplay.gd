extends ColorRect
class_name TileDetailsDisplay

var _selected_tile
var _display_components

func _init():
	_selected_tile = null
	_display_components = []

func register_component(component):
	if not _display_components.has(component):
		_display_components.append(component)

func selection_changed(prev, curr):
	if prev != null:
		prev.tile.tile_changed.disconnect(tile_changed)

	if curr != null:
		_selected_tile = curr.tile
		_selected_tile.tile_changed.connect(tile_changed)
		update_tile(_selected_tile)

	if curr != null:
		$VisibilityContainer.show()
	else:
		$VisibilityContainer.hide()

func tile_changed(change):
	update_tile(change.tile)

func update_tile(tile):
	var coords = tile.get_coords()
	var level_controller = LevelController.get_level_controller()

	for component in _display_components:
		component.update_tile(tile)
