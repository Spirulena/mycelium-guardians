class_name DecomposeButton extends Node2D

@export var name_label: Label
@export var texture_button: TextureButton

signal pressed

func _ready() -> void:
	texture_button.pressed.connect(button_pressed)

func button_pressed() -> void:
	pressed.emit()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3).from(1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
	# should be done up really
