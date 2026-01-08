extends Label
class_name SelectionInfoPresenter

func on_selection_changed(prev: TileObject, curr: TileObject):
	if curr == null:
		text = "Nothing, just terrain"
	else:
		var coords = curr.get_coords()
		var building_at = curr.get_building_type()
		var ruin_at = curr.get_ruin()
		text = "Tile at (%d, %d): Building type %d, ruin type %s" % [coords.x, coords.y, building_at, ruin_at]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
