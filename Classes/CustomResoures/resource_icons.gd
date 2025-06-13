extends Resource
class_name ResourceIcons

@export var icons_80px: Dictionary = {
	ResourceObject.ResourceType.Water: "H2O",
	ResourceObject.ResourceType.Energy: "ENERGY",
	ResourceObject.ResourceType.Minerals: "MINERALS",
	ResourceObject.ResourceType.Carbon: "CARBON",
	ResourceObject.SubResourceType.Acid: "ACID",
	ResourceObject.SubResourceType.Smog: "SMOG",
}

@export var icons_80px_array: Array[Texture2D]

func return_texture(resource_type: ResourceObject.ResourceType):
	return icons_80px_array[int(resource_type)]
