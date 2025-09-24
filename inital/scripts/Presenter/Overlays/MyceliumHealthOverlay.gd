extends Node2D

@export var on_build: float = -0.6
@export var on_removed: float = 0.6
@onready var tile_map: TileMap = %heatmap
@onready var tile_map_legend: CanvasLayer = $legend
enum TileArgs { layer, coords, source_id, atlas_coords, alternative_tile}
var tile_data: Array = []
func _init_tile_data():
	for i in range(0,4):
		for j in range(0,4):
			tile_data.append([0, null, 0, Vector2i(j, i), 0])


func _ready():
	_init_tile_data()
	_draw_overlay()
	hide()
	# Canvas layer have to be hiden manually, as does not inherit from the tree
	tile_map_legend.hide()

func toggle_overlay():
	visible = ! visible
	tile_map_legend.visible = visible

func show_overlay():
	visible = true
	tile_map_legend.visible = visible

func hide_overlay():
	visible = false
	tile_map_legend.visible = visible

func _draw_overlay():
	var level_controller = LevelController.get_level_controller()
	for coords in level_controller.get_all_tiles():
		if coords:
			var tile = level_controller.get_all_tiles()[coords]
			var mycelium = tile.get_mycelium()
			if mycelium != null:
				var health = mycelium.get_health()
				var tile_index = clampi((10 - health / 10), 0, 10) # health in range 0-100
				var this_tile_data = tile_data[tile_index]
				this_tile_data[TileArgs.coords] = coords
				tile_map.set_cell.callv(this_tile_data)
			else:
				tile_map.erase_cell(0, coords)

func _process(delta):
	if visible:
		_draw_overlay()
