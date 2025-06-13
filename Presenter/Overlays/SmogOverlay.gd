extends Node2D

@onready var tile_map: TileMap = $smog_heatmap
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
	visibility_changed.connect(_on_visiblit_changed)

func _on_model_changed(change):
	# FIX: make it so it does not have to listen to all changes
	# maybe just listen to tiles_changed ? make them reemied as diff then model_changed ?
	if change.type == 'smog':
		#if _lc.is_tile_visible_by_mycelium(change.tile):
		if change.tile.get_discovered():
			update_one_tile(change.tile)
	elif change.type == 'discovered':
		update_one_tile(change.tile)

func _redraw_all_if_cache_changed():
# if smog values are changed we need to redraw
	var new = _lc.get_all_tiles_visible_by_mycelium()
	if new == cache:
		return
	cache = new
	_draw_whole_overlay()

func _draw_whole_overlay():
	# How to check or cache smog levels

	for coords in cache.values():
		update_one_tile(coords)

# ADD level for tile ?
# add label if does not exist ?
# take it out of SmogTilePresenter ?
# OR SmogTilePresenter, react to overlay change

func update_one_tile(tile: TileObject):
	var coords = tile.get_coords()
	var value = clamp(tile.get_smog(), 0, 10)
	if value < 0.01:
		tile_map.erase_cell(0, coords)
		return
	#var tile_index = int(value * 10)
	var tile_index = clampi(int(value), 0, 10)
	var this_tile_data = tile_data[tile_index]
	this_tile_data[TileArgs.coords] = coords
	tile_map.set_cell.callv(this_tile_data)

func toggle_overlay():
	visible = ! visible
	tile_map_legend.visible = visible

func show_overlay():
	visible = true
	tile_map_legend.visible = visible

func hide_overlay():
	visible = false
	tile_map_legend.visible = visible

func _on_visiblit_changed():
	if visible:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED | SceneTree.GROUP_CALL_REVERSE, "smog_labels", "show")
	elif not visible:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED | SceneTree.GROUP_CALL_REVERSE,"smog_labels", "hide")
