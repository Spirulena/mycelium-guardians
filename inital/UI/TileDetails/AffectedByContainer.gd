extends VBoxContainer

@export var parent: Node

@onready var _icons: Dictionary = {}

func _ready():
	hide() # not used yet
	#parent.register_component(self)
	_icons = {
		"smog": $HBoxContainer/smog_factor_icon,
		"radiation": $HBoxContainer/radiation_factor_icon,
	}

func update_tile(tile):
	var mycelium_object = tile.get_mycelium()
	if mycelium_object != null:
		show()

		if LevelController.get_level_controller().get_smog(tile.get_coords()) > 0:
			_icons.get("smog").show()
		else:
			_icons.get("smog").hide()

		if LevelController.get_level_controller().get_radiation(tile.get_coords()) > 0:
			_icons.get("radiation").show()
		else:
			_icons.get("radiation").hide()
	else:
		hide()
