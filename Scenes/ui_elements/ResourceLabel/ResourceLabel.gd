extends Node2D

@export var resource_icons: ResourceIcons
@onready var amount_label:Label = %AmountLabel

var amount: float
var resource_type: ResourceObject.ResourceType
@onready var resource_icon: TextureRect = %ResourceIcon
@onready var to_color: Array = [%AmountLabel]

func _ready():
#	modulate.a = 0.0
	var sign_str = Utils.get_plus_sign_string(amount)
	amount_label.text = "%s%2.f" % [sign_str, amount]
	for element in to_color:
		element.modulate = ResourceObject.get_resource_type_color(resource_type)
	resource_icon.texture = resource_icons.return_texture(resource_type)
	# creat tiny random delay
	var location_tween: Tween = self.create_tween()
	location_tween.tween_property(self, "position:y", (self.position.y - 200.0), 3.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).from(0.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(1.0).from(1.0)
	tween.tween_callback(queue_free).set_delay(0.3)
