extends TileMap

enum TileStatus {HIGHLIGHT_GREEN, HIGHLIGHT_RED, SELECTED}
enum {LAYER, COORDS }
var tile_data: Dictionary = {
	TileStatus.HIGHLIGHT_GREEN: [0, null, 2, Vector2i(0, 0), 0],
	TileStatus.HIGHLIGHT_RED: [0, null, 2, Vector2i(0, 2), 0],
	TileStatus.SELECTED: [1, null, 2, Vector2i(0, 1), 0]
}

# A dictionary to emulate a set of currently highlighted tiles.
var active_tiles: Dictionary = {}
var selected_tiles: Array

var _lc: LevelController
func _ready():
	_lc = LevelController.get_level_controller()
	selected_tiles = []


func on_tiles_highlighted(coords: Vector2i, size: Vector2i, allowed: bool):
	var tile_type
	if allowed:
		tile_type = TileStatus.HIGHLIGHT_GREEN
	else:
		tile_type = TileStatus.HIGHLIGHT_RED
	_highlight_multiple_tiles(coords, size, tile_type)

func highlight_ruin(model: RuinObject):
	var tile_type = TileStatus.HIGHLIGHT_GREEN
	# Highlight the new tiles

	for coords in model.get_tile_coords():
		if not _lc.get_tile_at(coords).get_discovered():
			continue
		tile_data[tile_type][COORDS] = coords
		set_cell.callv(tile_data[tile_type])
		active_tiles[coords] = true

func _highlight_multiple_tiles(start_coords: Vector2i, size: Vector2i, tile_type):
	# Clear previously highlighted tiles of this type
	for coords in active_tiles.keys():
		erase_cell(tile_data[tile_type][LAYER], coords)
	active_tiles.clear()

	# Highlight the new tiles
	for x in range(size.x):
		for y in range(size.y):
			var coords = start_coords + Vector2i(x, y)
			tile_data[tile_type][COORDS] = coords
			set_cell.callv(tile_data[tile_type])
			active_tiles[coords] = true

func _on_tiles_selected(coords: Vector2i, size: Vector2i):
	if selected_tiles.size() > 0:
		_clear_selected_tiles(selected_tiles)
	selected_tiles.append(coords)
	_highlight_multiple_tiles(coords, size, TileStatus.SELECTED)

func _clear_highlighted_tiles():
	for coord in active_tiles.keys():
		for tile_type in [TileStatus.HIGHLIGHT_GREEN, TileStatus.HIGHLIGHT_RED, TileStatus.SELECTED]:
			erase_cell(tile_data[tile_type][LAYER], coord)
	active_tiles.clear()
	_clear_selected_tiles(selected_tiles)

func _clear_selected_tiles(tiles):
	for coord in tiles:
		var tile_type = TileStatus.SELECTED
		erase_cell(tile_data[tile_type][LAYER], coord)

func clear_all():
	clear()
