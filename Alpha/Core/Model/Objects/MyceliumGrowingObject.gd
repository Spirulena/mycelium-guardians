class_name MyceliumGrowingObject extends ModelObject

var _mycelium_gfx_index: int

func _init(coords, health = 100, myc_gfx_index: int = 0):
	super(ModelObject.Type.MyceliumGrowing, coords, health)
	_mycelium_gfx_index = myc_gfx_index
