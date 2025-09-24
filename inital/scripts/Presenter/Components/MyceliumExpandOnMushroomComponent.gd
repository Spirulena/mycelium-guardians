class_name MyceliumExpandOnMushroomComponent extends ViewComponent

func _ready() -> void:
	pass

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return

		#if change.state == 'place_request':
			#if LevelController.get_level_controller().grow_structure_at_coords(change.building_id, change.coords, change.radius)
				#_view.view_changed.emit({
					#'type': GUIController.Actions.GrowStructure,
					#'state': 'placed',
					#'coords': change.coords,
					#'instance': change.instance,
					#})

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Building:
		if change.prev == null:
			# New building
			var model: BuildingObject = change.curr
			#expand_to_cover_radius(model)
			emit_placed_signal(model)

func expand_to_cover_radius(_model: BuildingObject):
	# check if already covered
	var all_tiles = _lc.get_coords_in_circle(_model.get_coords(), _model.radius)
	_lc.place_mycelium_path(all_tiles) # TODO: do the check of level editor data from tileMap

# 	if (change.type == GUIController.Actions.Explore):
		#if change.state == 'placed':

func emit_placed_signal(_model: BuildingObject):
	var coords: Vector2i = _model.get_coords()
	var _tiles: Array[Vector2i] = _lc.get_coords_in_circle(_model.get_coords(), _model.radius)
	_view.view_changed.emit({
		'type': GUIController.Actions.Explore,
		'state': 'placed',# this is place request
		'coords': coords,
		'tiles': _tiles,
	})
