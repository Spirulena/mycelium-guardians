extends HBoxContainer

@export var parent: Node

func _ready():
	parent.register_component(self)

func update_tile(tile):
	var harvester_object = tile.get_harvester()
	if harvester_object != null:
		show()
		$HarvestType.text = ResourceObject.ResourceType.keys()[harvester_object.get_resource_type()]
	else:
		hide()
