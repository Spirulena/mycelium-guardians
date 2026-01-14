extends Label
class_name SelectionInfoPresenter

func on_selection_changed(prev: TileObject, curr: TileObject):
	if curr == null:
		text = "Nothing, just terrain"
	else:
		var coords = curr.get_coords()
		var building_at = curr.get_building_type()
		var ruin_at = curr.get_ruin()
		
		text = "Coords (%d, %d)\nLayer: %d\nResource: %s" % [
		coords.x,
		coords.y,
		building_at,
		ruin_at
		]
