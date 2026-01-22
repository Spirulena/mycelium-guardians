extends Label
class_name SelectionInfoPresenter

func on_selection_changed(prev: TileObject, curr: TileObject):
	if curr == null:
		text = "Nothing, just terrain"
	else:
		var coords = curr.coords
		var layers = curr.layers

		text = "Coords (%d, %d)" % [
			coords.x,
			coords.y,
		]

		for layer_i in len(layers):
			text += "\n%s: " % [GameTypes.layer_names[layer_i]]
			var object = layers[layer_i]
			if object == null:
				text += "Nothing"
			else:
				text += object.name
