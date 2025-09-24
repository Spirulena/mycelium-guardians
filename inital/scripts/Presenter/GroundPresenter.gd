class_name GroundPresenterComponent extends ViewComponent

# TODO: the edges of screen are here.
# Either separate
# So we do ground tiles then mask in separate.
# OR allow for ground controller to only do edges

@onready var _tile_map: TileMap
@onready var _tile_map_block:TileMap # source 13, 0,0 , l0

var _discovered_tiles: Dictionary
var x4_changed: bool

func _init(level_controller: LevelController, view: LevelView, gui: GUIController, component_name: String = '', args: Dictionary = {}):
	super._init(level_controller, view, gui, component_name, args)
	_tile_map = args.get('tile_map')
	_tile_map_block = args.get('tile_map_block')
	_discovered_tiles = {}
	x4_changed = false

func _ready():
	pass

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	# TODO: could also react to curr == false
	if change.type == 'discovered' and change.curr == true:
		# hide 1x
		apply_visibility(change.coords)
		if x4_changed:
			mask_1x_tiles(translate_coordinates_to_4x_map(change.coords))
		# unmask the disovered tile from the change
		un_mask_tile(change.coords + Vector2i(1,0))

func mask_1x_tiles(coords_4x: Vector2i):
	var base_coords = coords_4x * 4 + Vector2i(1,0)
	for x in range(4):
		for y in range(4):
			var coord_1x = base_coords + Vector2i(x, y)
			mask_tile(coord_1x)  # Example of hiding the tile, adjust as needed

func mask_tile(coords):
	if _lc.get_tile_at(coords).get_discovered():
		var source_id = _tile_map_block.get_cell_source_id(0, coords)
		if source_id != -1:
			un_mask_tile(coords)
		return
	_tile_map_block.set_cell(0, coords, 18, Vector2i.ZERO)

func un_mask_tile(coords):
	_tile_map_block.erase_cell(0, coords)

func apply_visibility(x4coord):
	x4_changed = false
	var coords = translate_coordinates_to_4x_map(x4coord)
	var source_id = _tile_map.get_cell_source_id(0, coords)
	if source_id == -1:
		_tile_map.set_cell(0, coords, 11, Vector2i(0,0))
		x4_changed = true

func translate_coordinates_to_4x_map(coords: Vector2i) -> Vector2i:
	var adjusted_x = coords.x if coords.x >= 0 else coords.x - 3
	var adjusted_y = coords.y if coords.y >= 0 else coords.y - 3
	return Vector2i(floor(adjusted_x / 4), floor(adjusted_y / 4))
