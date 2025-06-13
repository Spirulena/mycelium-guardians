extends Label

@export var parent: Node

func _ready():
	parent.register_component(self)

func update_tile(tile):
	var structure = tile.get_structure() as BuildingObject
	if structure != null:
		# TODO: move to BuildingsObject Class
		text = BuildingObject.names.get(structure.get_building_type(), "??")
	else:
		text = ""
