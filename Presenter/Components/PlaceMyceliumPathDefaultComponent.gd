class_name PlaceMyceliumPathDefaultComponent extends ViewComponent

# ref tileLayer
# pass LevelEditorInternal ?
@onready var level_editor: TileMapLayer
@onready var blocked: TileMapLayer
@onready var allowed: TileMapLayer

func _ready() -> void:
	pass

func setup():
	level_editor = _view.level_editor_tilemap
	blocked = level_editor.get_node("BlockMycelium")
	allowed = level_editor.get_node("AllowedMycelium")

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return
#
	if (change.type == GUIController.Actions.Explore):
		if change.state == 'placed':
			if change.tiles != null:
				#print_debug(change.tiles)
				# now we can sort based on passed LevelEditor,
				# blockMycelium List, AllowedMycelium List
				if level_editor != null:
					var blocked_v2: Array[Vector2i] = blocked.get_used_cells()
					var allowed_v2: Array[Vector2i] = allowed.get_used_cells()
					var filtered_tiles: Array[Vector2i] = []
					# Actually drawing path should take into account the blockade
					# for now check if any
					# can then indicate which tiles are blocked and blink them red
					if not blocked_v2.is_empty():
						for tile in change.tiles: # TODO: this is problematic with Mushrooms, Structers expansion
							if tile in blocked_v2:
								print_debug(tile, " in blocked list")
								return
					for tile in change.tiles:
						if tile in allowed_v2:
							filtered_tiles.append(tile)
					#var filtered_tiles = change.tiles.filter(func(tile): return tile in allowed_v2)
					_lc.place_mycelium_path(filtered_tiles)
				else:
					_lc.place_mycelium_path(change.tiles)
		#parent.view_changed({
			#'type': GUIController.Actions.Explore,
			#'state': 'placed',# this is place request
			#'coords': coords,
			#'tiles': _tiles,
		#})

		#LevelController.get_level_controller().place_mycelium_path(_tiles)
