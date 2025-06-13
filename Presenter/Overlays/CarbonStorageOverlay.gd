class_name CarbonStorageOverlayPresenter extends Node2D

@onready var tile_map: TileMap = $heatmap
@onready var tile_map_legend: CanvasLayer = $legend

@onready var resource_type: ResourceObject.ResourceType

var cache
var _lc: LevelController

enum TileArgs { layer, coords, source_id, atlas_coords, alternative_tile}
var tile_data: Array = []
func _init_tile_data():
	for i in range(0,4):
		for j in range(0,4):
			tile_data.append([0, null, 0, Vector2i(j, i), 0])

func _ready():
	resource_type = ResourceObject.ResourceType.Carbon
	_init_tile_data()

	_lc = LevelController.get_level_controller()
	_lc.model_changed.connect(_on_model_changed)

	# Hide on ready
	hide()
	tile_map_legend.hide()

	_redraw_all_if_cache_changed()

func _on_model_changed(change):
	if change.type == 'tile_resource' and change.resource_type == resource_type:
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

func update_one_tile(tile: TileObject):
	var coords = tile.get_coords()
	var value = tile._resources[resource_type]
	var clamped_value = clamp(tile._resources[resource_type], 0, 10)
	var tile_index = int(clamped_value)
	if value > 0:
		tile_index = 1

	var this_tile_data = tile_data[tile_index]
	this_tile_data[TileArgs.coords] = coords
	tile_map.set_cell.callv(this_tile_data)

func toggle_overlay():
	visible = ! visible
	tile_map_legend.visible = visible

func show_overlay():
	visible = true
	tile_map_legend.visible = visible
	var tween_a: Tween = self.create_tween()
	tween_a.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	#tween_a.tween_property(self, "modulate:a", 0.6, 0.1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)

func hide_overlay():
	visible = false
	tile_map_legend.visible = visible
