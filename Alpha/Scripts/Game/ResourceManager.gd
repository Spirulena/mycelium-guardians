extends Node
class_name ResourceManager
static var instance: ResourceManager

var resources : int = 50
@export var resource_Label : Label

func _ready():
	instance = self
	update_label()

func can_afford(cost: int) -> bool:
	return resources >= cost

func spend(cost: int):
	resources -= cost
	update_label()

func get_move_cost(path: PackedVector2Array) -> int:
	return path.size()

func update_label():
	if resource_Label:
		resource_Label.text = str(resources)
