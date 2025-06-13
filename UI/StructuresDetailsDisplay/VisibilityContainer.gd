extends ColorRect

@export var parent: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	parent.register_component(self)

func update_tile(tile):
	if tile.get_structure() != null:
		show()
	else:
		hide()

