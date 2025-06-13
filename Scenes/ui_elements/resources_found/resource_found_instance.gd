extends Node2D

@export var frames_array: Array[SpriteFrames]
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
var type: ResourceObject.ResourceType
signal finished

func _ready():
	animated_sprite.frame = 0
	label.modulate.a = 0.0
	_set_label()
	await get_tree().create_timer(1.0).timeout
	await _animate()
	get_tree().create_timer(1.0).timeout.connect(func(): queue_free())
	# TODO: use scenes pool


func _set_label():
	label.add_theme_color_override("font_color", ResourceObject.get_resource_type_color(type))
	label.text = "%s found!" % ResourceObject.get_resource_type_string(type)
	label.modulate.a = 0.0

# TODO: this could be in animation player
# Same with all awaits in _ready
func _animate():
	var label_tween: Tween = self.create_tween()
	label_tween.tween_property(label, "modulate:a", 1.0, 0.2).set_delay(0.2)
	label_tween.tween_property(label, "modulate:a", 0.0, 0.2).set_delay(0.8)

	modulate.a = 1.0
	animated_sprite.frame = 0
	animated_sprite.sprite_frames = frames_array[type]
	animated_sprite.play("default")
	await animated_sprite.animation_finished
	# show text with amount ?
	# fade out
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	finished.emit()
