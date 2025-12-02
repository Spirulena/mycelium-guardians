extends MovableObject
class_name CreatureObject

enum CreatureType {Worm, Moths, FFCrasher}
# Worm, FFCrasher is overground, 
# Moth is sky
# Use type like in ModelObject.Type

# NOTE: Worm moves differently. Spawns on location then needs to dissapear and
# be moved elsewhere

var _subtype: CreatureType

# TODO: subtypes: worms, birds ?

func _init(coords, subtype, health = 100):
	super(ModelObject.Type.Creature, coords, health)
	_subtype = subtype
	## FFCrasher have 3,3
	set_size(Vector2i(3, 3))

func get_subtype():
	return _subtype

func get_speed():
	return 0.2
#
#func get_occupied_coords():
	#var coords: Array = []
	#for dx in range(get_coords().x, get_coords().x + _size.x):
		#for dy in range(get_coords().y, get_coords().y + _size.y):
			#coords.append(Vector2i(dx, dy))
	#return coords
