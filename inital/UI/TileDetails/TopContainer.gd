extends ColorRect

@export var parent: Node

func _ready():
	parent.register_component(self)

func update_tile(tile):
	if tile == null:
		hide()
	else:
		show()
