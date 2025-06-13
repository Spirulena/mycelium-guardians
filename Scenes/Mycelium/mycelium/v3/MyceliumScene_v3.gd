class_name MyceliumScene extends Node2D

var _lc: LevelController

@export var animations: Array[SpriteFrames]
@export var center: AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _model:MyceliumObject

func set_model(model):
	_model = model
	center.sprite_frames = animations[_model._mycelium_gfx_index]
	var last = animations[_model._mycelium_gfx_index].get_frame_count("default")
	center.frame = last - 1

func _ready():
	_lc = LevelController.get_level_controller()

func pruned():
	var tween = self.create_tween()
	tween.tween_property($modulate, "modulate", Color(0.1, 0.1, 0.1, 0.8), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property($modulate, "modulate", Color(1.0, 0.3, 0.3, 0.8), 0.2).set_trans(Tween.TRANS_SINE)
	tween.set_loops(5)
	queue_free()

func thicken():
	animation_player.play("Purify")
