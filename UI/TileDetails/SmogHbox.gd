extends HBoxContainer

@export var parent: Node
@export var amount_label: Node

func _ready():
	parent.register_component(self)

func update_tile(tile):
	amount_label.text = "%d" % tile.get_smog()
