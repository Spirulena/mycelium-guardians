class_name CanBuildHereTileMap extends TileMap

var cache
var _lc: LevelController
var timer: Timer

func _ready():
	_lc = LevelController.get_level_controller()
	cache = _lc.get_all_tiles_where_can_build()

func _on_timeout():
	draw_tile_map()

# TODO: get all tiles that can grow on them
# All mycelium tiles,
# that do not have,
# - buildings,
# - havesters, # Will remove later
# - ruins
# - panels
# React to new mycelium added, can pass from LevelPresenter

func draw_tile_map():
	# Cache
	var new = _lc.get_all_tiles_where_can_build()
	if new == cache:
		return
	cache = new

	# Erase all cells and redraw. could remove and add change by change
	clear()
	# Paint where can build
	for coords in cache:
		#set_cell(0, coords, 0, Vector2i(0,0))
		#set_cell(0, coords, 1, Vector2i(5,0))
		set_cell(0, coords, 2, Vector2i(0,0))

## or call on timer every 1s
## Could hook up to mycelium_changed or state changed of mycelium
#func _process(delta):
	#draw_tile_map()
