extends Node2D

var anim_speed_mult: float

@onready var animation_player = $AnimationPlayer

func _init():
	randomize()
	anim_speed_mult = randf_range(0.2, 2.2)

func _ready():
	randomize()
	anim_speed_mult = randf_range(0.2, 2.2)
	animation_player.speed_scale = anim_speed_mult
