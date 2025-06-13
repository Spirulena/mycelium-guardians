extends Node2D

@onready var tile_map: TileMap = $heatmap
@onready var tile_map_legend: CanvasLayer = $legend

var cache
var _lc: LevelController

enum TileArgs { layer, coords, source_id, atlas_coords, alternative_tile}
var tile_data: Array = []
func _init_tile_data():
	for i in range(0,4):
		for j in range(0,4):
			tile_data.append([0, null, 0, Vector2i(j, i), 0])

func _ready():
	_init_tile_data()

	_lc = LevelController.get_level_controller()
	_lc.model_changed.connect(_on_model_changed)

	# Hide on ready
	hide()
	tile_map_legend.hide()

	_redraw_all_if_cache_changed()

func _on_model_changed(change):
	if change.type == 'radiation':
		if change.tile.get_discovered():
			update_one_tile(change.tile)
	elif change.type == 'discovered':
		update_one_tile(change.tile)

func _redraw_all_if_cache_changed():
	var new = _lc.get_all_tiles_visible_by_mycelium()
	if new == cache:
		return
	cache = new
	_draw_whole_overlay()

func _draw_whole_overlay():
	for coords in cache.values():
		update_one_tile(coords)

func update_one_tile(tile: TileObject):
	var coords = tile.get_coords()
	# Here is the only difference to SmogOverlay.gd,
	# either get_radiation or get_smog
	# get_property('radiation') ?
	var value = clamp(tile.get_radiation(), 0, 10)
	if value < 1:
		tile_map.erase_cell(0, coords)
		return
	#var tile_index = int(value * 10)
	var tile_index = clampi(int(value), 0, 10)
	var this_tile_data = tile_data[tile_index]
	this_tile_data[TileArgs.coords] = coords
	tile_map.set_cell.callv(this_tile_data)
## Animate, flicker the radius that it will have.

func toggle_overlay():
	visible = ! visible
	tile_map_legend.visible = visible

func show_overlay():
	visible = true
	tile_map_legend.visible = visible

func hide_overlay():
	visible = false
	tile_map_legend.visible = visible
