extends ModelObject
class_name RuinObject

var _ruin_type: String
var _connected_to_base: bool
var _connection_coords: Vector2i
var _have_ruin_text: bool
var _ruin_text: String
# NOTE: need to store data somewhere
# RuinType -> resources, resource relative position, scene, text
# CustomResource ? , json ?
var _resources: Array[ResourceObject]
var _harvesters: Array[HarvesterObject]
var _ruin_name: String
# Harvesters are accessible via _resources.
# Maybe drop harvesters
# just use ruin Controller ? To extract
# Decompose
# Use up enzymes

# TODO: instead of size -use-> pattern
func _init(coords, size, ruin_type, resources, health = 100):
	super(ModelObject.Type.Ruin, coords, health)
	set_size(size)
	_ruin_type = ruin_type
	_connected_to_base = false
	_connection_coords = Vector2i.ZERO
	_have_ruin_text = false
	_ruin_name = _ruin_names[_ruin_type]
	_ruin_text = _ruin_text_db[_ruin_type]
	_resources = resources

func get_resources() -> Array[ResourceObject]:
	return _resources

func set_ruin_text(text):
	_ruin_text = text

func get_ruin_text():
	return _ruin_text

func get_resources_text():
	var names:Array = []
	for resource_object in _resources:
		names.append(resource_object.get_resource_name())
	return ",".join(names)

# TODO: or get_subtype
# TODO: just get_type() ?
func get_ruin_type():
	return _ruin_type

# TODO: where to store, ruin text ?
# Load from file
var _ruin_names: Dictionary = {
	'ruin_apartament_01': "Apartament complex ruin",
	'ruin_tank_02': "Tank ruin",
	'ruin_mainer_01': "Crypto Miners Pile",
	'ruin_log_01': "Logs - Cycle of Decay",
	'ruin_log_02': "Logs - Renewal's Respite",
	'ruin_tree_stump_01': "Tree stumps",
	'ruin_tree_stump_01_256': "Tree stumps",
	'ruin_organic_matter': "Organic Matter"
}
# TODO: save this data somewhere else
# and default to something
var _ruin_text_db: Dictionary = {
	'ruin_apartament_01': "In the shadow of civilization's reach, an apartment complex stands, a testament to human ingenuity and its affinity for the skies. Once a hive of life, its halls now silent, it is a monument to the mastery of cement, steel, and glass, materials coaxed into defiance of gravity. These towering structures, born from the ambition to harness the elements and sculpt the very clouds, now lie empty, their purpose lost to time and turmoil",
	'ruin_tank_02': """In the aftermath of human conflict, we, the mycelial network, approach an abandoned tank, a relic of war, with a cosmic sense of purpose. With our enzymes as alchemical tools, we transmute this symbol of destruction into life, coaxing metals and plastics into nourishment for the earth. This act of transformation is a dance of atoms, a celebration of life's relentless urge to regenerate. Through this process, we not only reclaim the artifact of human aggression but also weave a new tapestry of life, embodying the psychedelic mystery that underscores our existence. In doing so, we remind the world of nature's profound ability to communicate and heal, echoing the wisdom that in the cycle of life and death, there lies the potential for rebirth and unity""",
	'ruin_mainer_01': """Amidst the remnants of a digital crusade, a pile of crypto miners lies dormant, whispering questions about the price of progress. Were these sentinels of decentralization harbingers of freedom, or bearers of unforeseen consequences? As they rest, their silent query lingers in the air: What does it truly mean to seek autonomy in an interconnected world, and at what cost does this quest come? These relics of ambition, now stilled, invite us to ponder the balance between technological aspirations and the environmental footprint left in their wake. Can the promise of a digital utopia coexist with the stewardship of our physical realm, or are these ideals inherently at odds?""",
	'ruin_log_01': "Nestled among fallen logs and weathered stumps, a testament to nature's relentless cycle stands. Fungi, silent yet vital, work diligently at decomposition, raising the question: Without these unsung heroes, would our forests be overrun by the fallen? This scene prompts a deeper inquiry into the roles these organisms play in recycling life's essentials. How might the ceaseless work of fungi reflect the larger cycles of growth and decay that govern the natural world?",
	'ruin_log_02': "Beside the remnants of ancient trees, the continuation of life's cycle is evident in the action of decay. As fungi transform wood into soil, one wonders about the implications of these processes for other aspects of life. What can humans learn from this natural efficiency, where nothing is wasted and everything serves a new purpose? Could the patterns of reuse and renewal found in nature inspire more sustainable practices in our own lives?",
	'ruin_tree_stump_01': "...",
	'ruin_tree_stump_01_256': "...",
	'ruin_organic_matter': "...",
}
