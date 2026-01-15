extends Label
class_name SelectionInfoPresenter

func on_selection_changed(prev: TileObject, curr: TileObject):
	if curr == null:
		text = "Nothing, just terrain"
	else:
		var coords = curr.get_coords()
		var building_at = curr.get_building_type()
		var ruin_at = curr.get_ruin()
		var mycelium_at = curr.get_mycelium()
		
		text = "Coords (%d, %d)\nLayer: %d\nResource: %s\nMycelium: %s" % [
		coords.x,
		coords.y,
		building_at,
		ruin_at,
		mycelium_at
		]
