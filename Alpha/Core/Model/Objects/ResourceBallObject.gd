extends MovableObject
class_name ResourceBallObject

var _resource_type: GameTypes.ResourceType
var _amount: float

func _init(coords, type, amount = 100):
	super(GameTypes.Type.ResourceBall, coords, 100)
	_resource_type = type
	_amount = amount

func get_resource_type():
	return _resource_type

func get_resource_amount():
	return _amount
