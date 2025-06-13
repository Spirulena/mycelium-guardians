extends Node2D

@export var resource_icons: ResourceIcons
@onready var amount_label:Label = %AmountLabel

# TODO: amount added need to be check in building resource

var amount: float
var resource_type: ResourceObject.ResourceType
@onready var resource_icon: TextureRect = %ResourceIcon
@onready var to_color: Array = [%MessageLabel, %AmountLabel, %Circle03, %Light03]

func _ready():
	var str_sign = Utils.get_plus_sign_string(amount)
	amount_label.text = "%s%s" % [str_sign, str(amount)]
	for element in to_color:
		element.modulate = ResourceObject.get_resource_type_color(resource_type)
	resource_icon.texture = resource_icons.return_texture(resource_type)
