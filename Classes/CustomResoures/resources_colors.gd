extends Resource
class_name ResourceColors

@export var resource_color: Dictionary = {
	ResourceObject.ResourceType.Water: Color("427ccb"),
	ResourceObject.ResourceType.Energy: Color("ffd166"),
	ResourceObject.ResourceType.Minerals: Color("ef476f"),
	ResourceObject.ResourceType.Carbon: Color("06d6a0"),
	ResourceObject.SubResourceType.Acid: Color(0.180392, 0.545098, 0.341176, 1),
	ResourceObject.SubResourceType.Smog: Color(0.501961, 0, 0.501961, 1),
}
