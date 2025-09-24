extends Node2D

@export var covered: Sprite2D

func _ready() -> void:
	covered.modulate.a = 0

func play_cover():
	var tween: Tween = self.create_tween()
	tween.tween_property(covered, "modulate:a", 1.0, 3.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
