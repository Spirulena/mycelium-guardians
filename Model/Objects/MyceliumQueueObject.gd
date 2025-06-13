class_name MyceliumQueueObject extends ModelObject

var minimum_required_water_level_for_expansion: float

func _init(coords, health = 100):
	super(ModelObject.Type.MyceliumQueue, coords, health)
	minimum_required_water_level_for_expansion = 0.3
