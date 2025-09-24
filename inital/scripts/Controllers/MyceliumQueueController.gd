class_name MyceliumQueueController extends Node2D

var _model: MyceliumQueueObject
var _lc: LevelController
var auto_expand_towards_water

func _init(model: MyceliumQueueObject):
	_model = model
	_lc = LevelController.get_level_controller()
	name = "MyceliumQueueController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

func _ready():
	if _lc.has_grown_neighbors(_model.get_coords()):
		transition_to_next_state()
	connect_to_hood_tiles()

func disconnect_hood_tiles():
	for tile in _lc.get_hood_tiles(_model.get_coords()):
		tile.tile_changed_direct.disconnect(_on_tile_changed_direct)

func connect_to_hood_tiles():
	for tile in _lc.get_hood_tiles(_model.get_coords()):
		tile.tile_changed_direct.connect(_on_tile_changed_direct)

		if should_expand_towards_water(tile):
			queue_mycelium_expansion_towards(tile)

func should_expand_towards_water(tile: TileObject) -> bool:
	if not _lc.auto_expand_mycelium_towards_water:
		return false
	var discovered = tile.get_discovered()
	return _lc.get_water_level(tile.get_coords()) >= _model.minimum_required_water_level_for_expansion and discovered

# Queues expansion towards the specified tile by creating a new MyceliumQueueObject aimed at that tile
func queue_mycelium_expansion_towards(target_tile: TileObject):
	var target_coords: Vector2i = target_tile.get_coords()
	_lc.add_object_guarded(MyceliumQueueObject.new(target_coords))

func _on_tile_changed_direct(change):
	# TODO: need to check if grown to the direction of this tile
	# center -> top, center->bottom, center->left, center->right
	# now we are growing whole path initially, so from left->center->right,
	# fill in the data. in tile. so other presenters can use that.
	# then can check dictionary.
	# if fully surrounded, potentialy just one need to grow towards it.
	if change.type == 'mycelium_grown':
		var tile = _lc.get_tile_at(_model.get_coords())
		var mycelium = tile.get_mycelium()
		disconnect_hood_tiles() # lack of this was making double MyceliumGrowing
		transition_to_next_state()

func transition_to_next_state():
	var tile = _lc.get_tile_at(_model.get_coords())
	var mycelium = tile.get_mycelium()
	if mycelium != null and mycelium.get_type() == ModelObject.Type.MyceliumGrowing:
		print_stack()
		return
	_lc.remove_object(_model)
	_lc.add_object_guarded(MyceliumGrowingObject.new(_model.get_coords()))
	queue_free()
