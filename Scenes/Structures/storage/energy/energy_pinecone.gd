extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation: Animation

var _model: BuildingObject
var _rand_speed_scale: float

func _init():
	pass

func set_model(model: BuildingObject):
	_model = model

func _ready():
	_rand_speed_scale = randf_range(0.8, 1.2)
	animation_player.get_animation("cycle").resource_local_to_scene = true
	animation = animation_player.get_animation("cycle")

func adjust_speed(factor: float):
	animation_player.speed_scale = _rand_speed_scale * factor

func start_cycle():
	animation_player.speed_scale = _rand_speed_scale
	animation_player.play("cycle")

func pause_cycle():
	animation.loop_mode = Animation.LOOP_NONE

func un_pause_cycle():
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play()
