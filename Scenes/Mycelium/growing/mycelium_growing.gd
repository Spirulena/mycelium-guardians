class_name MyceliumGrowingScene extends Node2D

@export var animations: Array[SpriteFrames]
@export var center: AnimatedSprite2D

func set_frames(index: int):
	center.sprite_frames = animations[index]
	center.autoplay = "default"
