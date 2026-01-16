extends Node
class_name GameTypes

const Type = {
	"AIPanel": "ai_panel",
	"Building": "building",
	"Harvester": "harvester",
	"Ruin": "ruin",
	"Mycelium": "mycelium",
	"MyceliumQueue": "mycelium_queue",
	"MyceliumGrowing": "mycelium_growing",
	"Enzyme": "enzyme",
	"Resource": "resource",
	"Creature": "creature", # Movable
	"Plant": "plant",
	"ResourceBall": "resource_ball" # Movable
}

const object_to_layer_map = {
	Type.AIPanel: Layer.Overground,
	Type.Building: Layer.Overground,
	Type.Ruin: Layer.Overground,
	Type.Plant: Layer.Overground,
	Type.Harvester: Layer.Overground,
	Type.Creature: Layer.Overground,
	Type.Mycelium: Layer.Mycelium,
	Type.ResourceBall: Layer.Mycelium,
}

enum Layer { Sky=0, Overground, Mycelium, Underground, NUM_LAYERS }
const layer_names = ["Sky", "Overground", "Mycelium", "Underground"]

enum ResourceType { Water=0, Minerals, Energy, Carbon, NUM_RESOURCES }
const resource_names = ["Water", "Minerals", "Energy", "Carbon"]
