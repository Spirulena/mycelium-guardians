extends HBoxContainer

@export var parent: Node

func _ready():
	parent.register_component(self)

func update_tile(tile):
	$Coords.text = "(%d, %d)" % [tile.get_coords().x, tile.get_coords().y]
