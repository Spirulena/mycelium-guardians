extends HBoxContainer

@export var parent: Node

func _ready():
	parent.register_component(self)

func update_tile(tile):
	$DistanceValue.text = "%d" % LevelController.get_level_controller().distance_to_base(tile.get_coords())
