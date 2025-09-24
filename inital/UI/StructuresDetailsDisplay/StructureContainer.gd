extends Label

@export var parent: Node

func _ready():
	parent.register_component(self)

func update_tile(tile):
	var structure = tile.get_structure()
	if structure != null:
		# TODO: move to BuildingsObject Class
		text = BuildingObject.get_building_category_string(structure.get_building_type())
	else:
		text = ""
