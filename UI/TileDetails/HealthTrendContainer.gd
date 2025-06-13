extends HBoxContainer

@export var parent: Node

func update_tile(tile):
	var mycelium_object = tile.get_mycelium()
	if mycelium_object != null:
		show()
		if (LevelController.get_level_controller().get_smog(tile.get_coords()) > 0
			or LevelController.get_level_controller().get_radiation(tile.get_coords())):
				$trend_label.text = "decreasing"
		else:
			$trend_label.text = "stable"
	else:
		hide()
